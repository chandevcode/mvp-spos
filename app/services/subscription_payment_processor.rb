class SubscriptionPaymentProcessor
  def self.process_successful_payment(subscription_payment)
    return if subscription_payment.success?

    # Determine if this is an extension or a new registration
    if subscription_payment.tenant.present?
      process_extension_payment(subscription_payment)
    else
      process_new_registration_payment(subscription_payment)
    end
  end

  def self.process_new_registration_payment(subscription_payment)
    return unless subscription_payment.password_digest.present?
    return unless subscription_payment.email.present?
    return unless subscription_payment.tenant_name.present?
    return unless subscription_payment.name.present?

    ActiveRecord::Base.transaction do
      # Create the tenant
      tenant = Tenant.create!(
        name: subscription_payment.tenant_name,
        subdomain: generate_subdomain(subscription_payment.tenant_name)
      )

      # Create the user with the pre-encrypted password
      user = User.new(
        email: subscription_payment.email,
        name: subscription_payment.name,
        address: subscription_payment.address,
        phone_number: subscription_payment.phone_number,
        tenant: tenant,
        role: :owner
      )
      user.skip_password_validation = true
      user.encrypted_password = subscription_payment.password_digest
      user.save!

      # Activate the subscription
      tenant.activate_subscription!(subscription_payment.plan_type)

      # Update subscription payment
      subscription_payment.update!(
        status: :success,
        tenant: tenant,
        user: user
      )

      # Send welcome email
      UserMailer.registration_success(user, subscription_payment).deliver_later
    end
  end

  def self.process_extension_payment(subscription_payment)
    tenant = subscription_payment.tenant
    return unless tenant

    ActiveRecord::Base.transaction do
      # Extend the subscription from now
      new_expiry = if tenant.subscription_expires_at.present? && tenant.subscription_expires_at > Time.current
                     # Extend from current expiry date
                     case subscription_payment.plan_type
                     when "monthly" then tenant.subscription_expires_at + 1.month
                     when "annual" then tenant.subscription_expires_at + 12.months
                     else tenant.subscription_expires_at + 1.month
                     end
                   else
                     # Was expired or never set — start from now
                     case subscription_payment.plan_type
                     when "monthly" then 1.month.from_now
                     when "annual" then 12.months.from_now
                     else 1.month.from_now
                     end
                   end

      tenant.update!(
        subscription_status: :active,
        subscription_plan: subscription_payment.plan_type,
        subscribed_at: Time.current,
        subscription_expires_at: new_expiry
      )

      # Update subscription payment
      subscription_payment.update!(status: :success)
    end
  end

  def self.verify_and_process(subscription_payment)
    # Check if already processed
    return { status: "success" } if subscription_payment.success?

    begin
      # Query Midtrans API for current transaction status
      response = Veritrans.status(subscription_payment.midtrans_order_id)

      if response&.data
        # NOTE: Veritrans::Result converts response keys to symbols internally
        transaction_status = response.transaction_status
        fraud_status = response.fraud_status

        # Update with latest data
        subscription_payment.update!(
          midtrans_transaction_id: response.transaction_id,
          midtrans_status: transaction_status,
          midtrans_payment_type: response.payment_type,
          gross_amount: response.gross_amount,
          transaction_time: parse_datetime(response.transaction_time),
          settlement_time: parse_datetime(response.settlement_time)
        )

        case transaction_status
        when "capture", "settlement"
          if fraud_status == "accept" || fraud_status.nil? || fraud_status == "challenge"
            process_successful_payment(subscription_payment)
            return { status: "success" }
          end
        when "accept"
          process_successful_payment(subscription_payment)
          return { status: "success" }
        when "deny", "cancel", "expire", "failure"
          subscription_payment.update!(status: :failed)
          return { status: "failed" }
        when "pending"
          return { status: "pending" }
        end
      end

      { status: subscription_payment.status }
    rescue StandardError => e
      Rails.logger.error("Midtrans status check error: #{e.message}")
      { status: subscription_payment.status }
    end
  end

  private

  def self.generate_subdomain(name)
    base = name.parameterize.tr("_", "-")
    subdomain = base
    counter = 1
    while Tenant.exists?(subdomain: subdomain)
      subdomain = "#{base}-#{counter}"
      counter += 1
    end
    subdomain
  end

  def self.parse_datetime(datetime_str)
    return nil unless datetime_str.present?
    Time.parse(datetime_str)
  rescue ArgumentError
    nil
  end
end
