# frozen_string_literal: true

# Midtrans has two separate environments (api hosts + keys + Snap SDK hosts).
# Default follows Rails.env, but override with MIDTRANS_ENV=sandbox|production
# so e.g. sandbox payments work on a production deploy for testing.
# Named MidtransEnvironment because the veritrans gem aliases Midtrans = Veritrans.
module MidtransEnvironment
  module_function

  def environment
    ENV.fetch("MIDTRANS_ENV", Rails.env.production? ? "production" : "sandbox")
  end

  def production?
    environment == "production"
  end

  def api_host
    production? ? "https://api.midtrans.com" : "https://api.sandbox.midtrans.com"
  end

  def snap_js_url
    production? ? "https://app.midtrans.com/snap/snap.js" : "https://app.sandbox.midtrans.com/snap/snap.js"
  end
end
