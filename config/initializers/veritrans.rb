# frozen_string_literal: true

# Veritrans config needs app code (MidtransEnvironment), which is only autoloadable
# after boot — hence after_initialize.
Rails.application.config.after_initialize do
  midtrans_creds = Rails.application.credentials.dig(:midtrans)
  api_host = MidtransEnvironment.api_host

  Veritrans.setup do
    config.server_key = midtrans_creds&.dig(:server_key) || ENV.fetch("MIDTRANS_SERVER_KEY", nil)
    config.client_key = midtrans_creds&.dig(:client_key) || ENV.fetch("MIDTRANS_CLIENT_KEY", nil)

    config.api_host = api_host
  end
end
