class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.all
    @products = @products.where(category: params[:category]) if params[:category].present?
    @products = @products.where("name LIKE ?", "%#{params[:search]}%") if params[:search].present?
  end
end
