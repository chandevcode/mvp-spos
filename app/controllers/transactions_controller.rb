class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @transaction = current_user.transactions.find(params[:id])
  end
end
