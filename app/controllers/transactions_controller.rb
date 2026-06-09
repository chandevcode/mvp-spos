class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner

  def update
    @transaction = Transaction.find(params[:id])
    if @transaction.update(status: :canceled)
      redirect_to dashboard_path, notice: "Transaction # #{@transaction.id} was canceled."
    else
      redirect_to dashboard_path, alert: "Unable to cancel transaction."
    end
  end

  private

  def authorize_owner
    redirect_to root_path, alert: "Access denied" unless current_user.owner?
  end
end
