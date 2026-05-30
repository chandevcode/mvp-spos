class CartController < ApplicationController
  before_action :authenticate_user!, only: [:checkout]

  def add
    product_id = params[:product_id]
    cart[product_id] = cart[product_id].to_i + 1
    redirect_back fallback_location: root_path, notice: "Added to cart"
  end

  def remove
    product_id = params[:product_id]
    if cart[product_id].to_i > 1
      cart[product_id] -= 1
    else
      cart.delete(product_id)
    end
    redirect_back fallback_location: root_path
  end

  def clear
    session[:cart] = {}
    redirect_to root_path, notice: "Cart cleared"
  end

  def show
  end

  def checkout
    transaction = current_user.transactions.create!(
      total_price: cart_total,
      status: :success
    )

    cart.each do |product_id, quantity|
      product = Product.find(product_id)
      transaction.transaction_items.create!(
        product: product,
        quantity: quantity,
        price: product.price
      )
    end

    session[:cart] = {}
    if params[:print] == "true"
      redirect_to transaction_path(transaction), notice: "Order completed successfully!"
    else
      redirect_to root_path, notice: "Order completed successfully!"
    end
  end
end
