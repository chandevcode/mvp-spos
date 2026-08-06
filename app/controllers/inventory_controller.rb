class InventoryController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_or_owner
  before_action :check_subscription

  def index
    @products = Product.order(:name)
    @low_stock_count = Product.low_stock.count
    @out_of_stock_count = Product.out_of_stock.count
    @total_products = Product.count
  end

  def update_stock
    @product = Product.find(params[:id])
    adjustment = params[:adjustment].to_i
    new_stock = @product.stock_quantity + adjustment

    if new_stock >= 0 && @product.update(stock_quantity: new_stock)
      redirect_to inventory_index_path, notice: "#{@product.name} stock updated to #{new_stock}"
    else
      redirect_to inventory_index_path, alert: "Invalid stock adjustment"
    end
  end

  def set_stock
    @product = Product.find(params[:id])
    new_stock = params[:stock_quantity].to_i

    if new_stock >= 0 && @product.update(stock_quantity: new_stock)
      redirect_to inventory_index_path, notice: "#{@product.name} stock set to #{new_stock}"
    else
      redirect_to inventory_index_path, alert: "Invalid stock value"
    end
  end

  private

  def authorize_admin_or_owner
    redirect_to root_path, alert: "Access denied" unless current_user.admin? || current_user.owner?
  end
end
