class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  set_current_tenant_through_filter
  before_action :set_tenant
  before_action :require_active_subscription
  before_action :initialize_cart

  private

  # Expired accounts may only reach their profile to extend the plan.
  # Exempted in ProfilesController and SubscriptionsController (the extend flow).
  def require_active_subscription
    return unless user_signed_in?

    tenant = current_user.tenant
    return unless tenant

    unless tenant.subscribed?
      redirect_to edit_profile_path, notice: "Your subscription is not active. Please extend your plan to continue using SPOS."
    end
  end

  def check_subscription
    return unless user_signed_in?

    tenant = current_user.tenant
    return unless tenant

    if tenant.expired? || (tenant.subscription_expires_at.present? && tenant.subscription_expires_at < Time.current)
      flash.now[:subscription_expired] = true
    elsif tenant.days_until_expiry <= 7 && tenant.days_until_expiry >= 0
      flash.now[:subscription_expiring] = tenant.days_until_expiry
    end
  end

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
