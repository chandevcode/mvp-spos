class RegistrationsController < ApplicationController
  layout "registration"
  skip_before_action :set_tenant, only: [:new, :create, :choose_plan, :payment, :payment_status, :success, :check_email]

  PLAN_PRICES = { "monthly" => 100_000, "annual" => 1_000_000 }.freeze

  def new
    @plan_type = params[:plan].presence_in(%w[monthly annual])
    unless @plan_type
      redirect_to register_path and return
    end

    @subscription_payment = SubscriptionPayment.new(plan_type: @plan_type)
  end

  def choose_plan
  end

  def create
    @plan_type = params[:plan_type].presence_in(%w[monthly annual])
    @subscription_payment = SubscriptionPayment.new(plan_type: @plan_type)

    # Validate required fields
    errors = []
    errors << "Plan type must be selected" unless @plan_type
    errors << "Owner name can't be blank" if params[:name].blank?
    errors << "Email can't be blank" if params[:email].blank?
    errors << "Restaurant name can't be blank" if params[:tenant_name].blank?
    errors << "Password can't be blank" if params[:password].blank?
    errors << "Password confirmation doesn't match" if params[:password] != params[:password_confirmation]

    if params[:password].present? && params[:password].length < 6
      errors << "Password is too short (minimum is 6 characters)"
    end

    if params[:email].present? && User.exists?(email: params[:email])
      flash[:alert] = "This email is already registered. Please sign in and extend your subscription from your profile."
      redirect_to new_user_session_path(email: params[:email]) and return
    end

    unless params[:email].to_s.match?(Devise.email_regexp)
      errors << "Email is invalid"
    end

    if errors.any?
      flash.now[:alert] = errors.first
      @subscription_payment = SubscriptionPayment.new(plan_type: @plan_type)
      render :new, status: :unprocessable_entity and return
    end

    # Create subscription payment with encrypted password
    @subscription_payment = SubscriptionPayment.new(
      email: params[:email],
      name: params[:name],
      address: params[:address],
      phone_number: params[:phone_number],
      tenant_name: params[:tenant_name],
      plan_type: @plan_type,
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    @subscription_payment.save!

    # Generate Midtrans Snap transaction
    begin
      transaction_details = {
        order_id: @subscription_payment.midtrans_order_id,
        gross_amount: @subscription_payment.amount.to_i
      }

      customer_details = {
        email: @subscription_payment.email
      }

      item_details = [
        {
          id: "SUB-#{@subscription_payment.plan_type.upcase}",
          price: @subscription_payment.amount.to_i,
          quantity: 1,
          name: "SPOS #{@subscription_payment.plan_type.titleize} Subscription"
        }
      ]

      snap_params = {
        transaction_details: transaction_details,
        customer_details: customer_details,
        item_details: item_details,
        callbacks: {
          finish: register_success_url,
          error: root_url,
          pending: root_url
        }
      }

      response = Veritrans.create_snap_token(snap_params)

      if response&.token
        @subscription_payment.update!(
          snap_token: response.token,
          snap_redirect_url: response.redirect_url
        )
        redirect_to register_payment_path(@subscription_payment)
      else
        @subscription_payment.update!(status: :failed)
        flash[:alert] = "Payment gateway is temporarily unavailable. Please try again."
        redirect_to register_path
      end
    rescue StandardError => e
      Rails.logger.error("Midtrans Snap Error: #{e.message}")
      @subscription_payment.update!(status: :failed, midtrans_status: "error: #{e.message}")
      flash[:alert] = "Payment system error. Please try again."
      redirect_to register_path
    end
  end

  def payment
    @subscription_payment = SubscriptionPayment.find(params[:id])
    if @subscription_payment.success?
      redirect_to register_success_path(email: @subscription_payment.email) and return
    end
  end

  def payment_status
    @subscription_payment = SubscriptionPayment.find(params[:id])

    # If still pending, verify directly with Midtrans API
    # (handles case where webhook didn't reach localhost)
    if @subscription_payment.pending?
      result = SubscriptionPaymentProcessor.verify_and_process(@subscription_payment)
      @subscription_payment.reload
    end

    render json: { status: @subscription_payment.status }
  end

  def check_email
    email = params[:email].to_s.strip.downcase

    if email.blank?
      render json: { exists: false, message: "" } and return
    end

    exists = User.exists?(email: email)

    if exists
      render json: { exists: true, message: "This email already has an account. Please sign in instead." }
    else
      render json: { exists: false, message: "" }
    end
  end

  def success
    @email = params[:email]

    # Midtrans may redirect directly here after payment (from callbacks.finish URL)
    # In that case, the payment hasn't been processed yet — verify and create account now
    order_id = params[:order_id]
    subscription_payment = nil

    if order_id.present?
      subscription_payment = SubscriptionPayment.find_by(midtrans_order_id: order_id)
    elsif @email.present?
      subscription_payment = SubscriptionPayment.where(email: @email).order(created_at: :desc).first
    end

    if subscription_payment
      unless subscription_payment.success?
        SubscriptionPaymentProcessor.verify_and_process(subscription_payment)
        subscription_payment.reload
      end

      @email = subscription_payment.email if @email.blank?

      if subscription_payment.success? && subscription_payment.user.present?
        # Account was successfully created — show the success page
      end
    end
  end
end
