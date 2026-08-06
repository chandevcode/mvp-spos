class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner
  before_action :check_subscription

  def index
    @start_date = params[:start_date]&.to_date || 7.days.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.today

    @transactions = Transaction.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(10)
    
    @success_count = Transaction.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).success.count
    @canceled_count = Transaction.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).canceled.count
    @total_revenue = Transaction.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).success.sum(:total_price)
    
    @all_transactions = Transaction.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    @low_stock_products = Product.low_stock.order(:stock_quantity)
    @out_of_stock_products = Product.out_of_stock.order(:name)
  end

  private

  def authorize_owner
    redirect_to root_path, alert: "Access denied" unless current_user.owner?
  end
end
