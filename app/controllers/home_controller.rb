class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :check_subscription

  def index
    @q = Product.ransack(params[:q])
    # Map simple params to Ransack predicates for backward compatibility
    @q.name_or_description_cont = params[:search] if params[:search].present?
    @q.category_eq = Product.categories[params[:category]] if params[:category].present?
    @products = @q.result.includes(:image_attachment).page(params[:page]).per(12)
  end
end
