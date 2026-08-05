# frozen_string_literal: true

midtrans_creds = Rails.application.credentials.dig(:midtrans)

Veritrans.setup do
  config.server_key = midtrans_creds&.dig(:server_key) || ENV.fetch("MIDTRANS_SERVER_KEY", nil)
  config.client_key = midtrans_creds&.dig(:client_key) || ENV.fetch("MIDTRANS_CLIENT_KEY", nil)

  config.api_host = if Rails.env.production?
                      "https://api.midtrans.com"
                    else
                      "https://api.sandbox.midtrans.com"
                    end
end
