class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :initialize_cart

  private

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
