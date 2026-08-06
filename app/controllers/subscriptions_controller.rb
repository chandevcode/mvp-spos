class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def extend_plan
    @tenant = current_user.tenant
  end

  def create_extend
    @tenant = current_user.tenant
    @plan_type = params[:plan_type].presence_in(%w[monthly annual])

    unless @plan_type
      redirect_to extend_subscription_path, alert: "Please select a plan" and return
    end

    # Create subscription payment linked to existing tenant/user
    @subscription_payment = SubscriptionPayment.new(
      email: current_user.email,
      tenant_name: @tenant.name,
      plan_type: @plan_type,
      tenant: @tenant,
      user: current_user
    )

    # No password needed for extension — use a dummy password digest
    @subscription_payment.password_digest = "extension-#{SecureRandom.hex(16)}"
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
          id: "EXT-#{@subscription_payment.plan_type.upcase}",
          price: @subscription_payment.amount.to_i,
          quantity: 1,
          name: "SPOS #{@subscription_payment.plan_type.titleize} — Extension"
        }
      ]

      snap_params = {
        transaction_details: transaction_details,
        customer_details: customer_details,
        item_details: item_details,
        callbacks: {
          finish: extend_subscription_success_url,
          error: edit_profile_url,
          pending: edit_profile_url
        }
      }

      response = Veritrans.create_snap_token(snap_params)

      if response&.token
        @subscription_payment.update!(
          snap_token: response.token,
          snap_redirect_url: response.redirect_url
        )
        redirect_to extend_subscription_payment_path(@subscription_payment)
      else
        @subscription_payment.update!(status: :failed)
        flash[:alert] = "Payment gateway is temporarily unavailable. Please try again."
        redirect_to extend_subscription_path
      end
    rescue StandardError => e
      Rails.logger.error("Midtrans Snap Error (extension): #{e.message}")
      @subscription_payment.update!(status: :failed, midtrans_status: "error: #{e.message}")
      flash[:alert] = "Payment system error. Please try again."
      redirect_to extend_subscription_path
    end
  end

  def extend_payment
    @subscription_payment = current_user.tenant.subscription_payments.find(params[:id])
  end

  def extend_payment_status
    @subscription_payment = current_user.tenant.subscription_payments.find(params[:id])

    if @subscription_payment.pending?
      SubscriptionPaymentProcessor.verify_and_process(@subscription_payment)
      @subscription_payment.reload
    end

    render json: { status: @subscription_payment.status }
  end

  def extend_success
    # Find the latest successful extension payment for this tenant
    @subscription_payment = current_user.tenant.subscription_payments
                                .where(plan_type: %w[monthly annual])
                                .order(created_at: :desc)
                                .first

    if @subscription_payment && !@subscription_payment.success?
      # Try to verify the payment
      order_id = params[:order_id]
      if order_id.present?
        payment = current_user.tenant.subscription_payments.find_by(midtrans_order_id: order_id)
        SubscriptionPaymentProcessor.verify_and_process(payment) if payment
        @subscription_payment = payment
      else
        SubscriptionPaymentProcessor.verify_and_process(@subscription_payment)
      end
      @subscription_payment.reload
    end
  end
end
