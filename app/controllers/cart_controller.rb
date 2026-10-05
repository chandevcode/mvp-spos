class CartController < ApplicationController
  before_action :authenticate_user!, only: [ :checkout ]

  def add
    product_id = params[:product_id]
    product = Product.find_by(id: product_id)

    unless product&.in_stock?
      respond_to do |format|
        format.html do
          if turbo_frame_request?
            render partial: "cart/floating_button_frame"
          else
            redirect_back fallback_location: root_path, alert: "#{product&.name || 'Product'} is out of stock"
          end
        end
      end and return
    end

    current_qty = cart[product_id].to_i

    if current_qty >= product.stock_quantity
      respond_to do |format|
        format.html do
          if turbo_frame_request?
            render partial: "cart/floating_button_frame"
          else
            redirect_back fallback_location: root_path, alert: "Not enough stock available for #{product.name}"
          end
        end
      end and return
    end

    cart[product_id] = current_qty + 1

    respond_to do |format|
      format.html do
        case turbo_frame_request_id
        when "cart-floating" then render partial: "cart/floating_button_frame"
        when "cart-content"  then render partial: "cart/content_frame"
        else
          redirect_back fallback_location: root_path, notice: "Added to cart"
        end
      end
    end
  end

  def remove
    product_id = params[:product_id]
    if cart[product_id].to_i > 1
      cart[product_id] -= 1
    else
      cart.delete(product_id)
    end

    respond_to do |format|
      format.html do
        case turbo_frame_request_id
        when "cart-floating" then render partial: "cart/floating_button_frame"
        when "cart-content"  then render partial: "cart/content_frame"
        else
          redirect_back fallback_location: root_path
        end
      end
    end
  end

  def clear
    session[:cart] = {}

    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "cart/content_frame"
        else
          redirect_to root_path, notice: "Cart cleared"
        end
      end
    end
  end

  def show
  end

  class InsufficientStock < StandardError; end

  def checkout
    if cart.blank?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    transaction = nil

    ActiveRecord::Base.transaction do
      transaction = current_user.transactions.create!(
        total_price: cart_total,
        status: :success,
        payment_method: params[:payment_method]
      )

      cart.each do |product_id, quantity|
        quantity = quantity.to_i
        product  = Product.find(product_id)

        transaction.transaction_items.create!(
          product: product,
          quantity: quantity,
          price: product.price
        )

        # Decrement in SQL, only if there is enough stock
        updated = Product
          .where(id: product.id)
          .where("stock_quantity >= ?", quantity)
          .update_all([ "stock_quantity = stock_quantity - ?", quantity ])

        if updated.zero?
          raise InsufficientStock, "#{product.name} has insufficient stock. Please update your cart."
        end
      end
    end

    session[:cart] = {}

    if params[:print] == "true"
      redirect_to transaction_path(transaction), notice: "Order completed successfully!"
    else
      redirect_to root_path, notice: "Order completed successfully!"
    end
  rescue InsufficientStock => e
    redirect_to cart_path, alert: e.message
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "A product in your cart no longer exists."
  end
end
