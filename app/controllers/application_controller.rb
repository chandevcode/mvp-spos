class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  set_current_tenant_through_filter
  before_action :set_tenant
  before_action :initialize_cart

  private

  def set_tenant
    tenant = if current_user
               current_user.tenant
             elsif session[:tenant_id]
               Tenant.find_by(id: session[:tenant_id])
             end

    # Fallback to first tenant for unauthenticated browsing
    tenant ||= Tenant.first

    if tenant
      # Clear cart if tenant changed (e.g., after login/logout)
      if session[:tenant_id].present? && session[:tenant_id] != tenant.id
        session[:cart] = {}
      end

      session[:tenant_id] = tenant.id
      set_current_tenant(tenant)
    end
  end

  def initialize_cart
    session[:cart] ||= {}
  end

  def cart
    session[:cart]
  end
  helper_method :cart

  def cart_total
    cart.sum { |id, qty| Product.find_by(id: id)&.price.to_f * qty }
  end
  helper_method :cart_total

  def cart_count
    cart.values.sum
  end
  helper_method :cart_count
end
