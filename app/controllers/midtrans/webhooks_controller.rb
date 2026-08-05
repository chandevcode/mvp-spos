module Midtrans
  class WebhooksController < ActionController::Base
    skip_before_action :verify_authenticity_token
    skip_before_action :set_tenant, if: -> { defined?(set_tenant) }

    def notification
      payload = JSON.parse(request.body.read)
      order_id = payload["order_id"]
      transaction_status = payload["transaction_status"]
      fraud_status = payload["fraud_status"]
      transaction_id = payload["transaction_id"]
      payment_type = payload["payment_type"]
      gross_amount = payload["gross_amount"]
      transaction_time = payload["transaction_time"]
      settlement_time = payload["settlement_time"]

      # Verify signature
      server_key = Rails.application.credentials.dig(:midtrans, :server_key) || ENV["MIDTRANS_SERVER_KEY"]
      signature = payload["signature_key"]

      expected = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new("sha512"),
        server_key,
        "#{order_id}#{transaction_status}#{gross_amount}#{server_key}"
      )

      unless secure_compare(signature, expected)
        render json: { status: "error", message: "Invalid signature" }, status: :unauthorized and return
      end

      # Find the subscription payment
      subscription_payment = SubscriptionPayment.find_by(midtrans_order_id: order_id)

      unless subscription_payment
        render json: { status: "error", message: "Order not found" }, status: :not_found and return
      end

      # Update payment info
      subscription_payment.update!(
        midtrans_transaction_id: transaction_id,
        midtrans_status: transaction_status,
        midtrans_payment_type: payment_type,
        gross_amount: gross_amount,
        transaction_time: parse_midtrans_datetime(transaction_time),
        settlement_time: parse_midtrans_datetime(settlement_time)
      )

      # Determine final status and process payment if successful
      case transaction_status
      when "capture", "settlement"
        if fraud_status == "accept" || fraud_status.nil? || fraud_status == "challenge"
          SubscriptionPaymentProcessor.process_successful_payment(subscription_payment)
        end
      when "accept"
        SubscriptionPaymentProcessor.process_successful_payment(subscription_payment)
      when "deny", "cancel", "expire", "failure"
        subscription_payment.update!(status: :failed)
      when "pending"
        subscription_payment.update!(status: :pending)
      end

      render json: { status: "ok" }
    end

    private

    def parse_midtrans_datetime(datetime_str)
      return nil unless datetime_str.present?
      Time.parse(datetime_str)
    rescue ArgumentError
      nil
    end

    def secure_compare(a, b)
      return false unless a.is_a?(String) && b.is_a?(String)
      ActiveSupport::SecurityUtils.secure_compare(a, b)
    end
  end
end
