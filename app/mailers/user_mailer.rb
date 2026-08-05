class UserMailer < ApplicationMailer
  def purchase_confirmation(user, transaction)
    @user = user
    @transaction = transaction
    @items = transaction.transaction_items.includes(:product)
    mail(to: @user.email, subject: "Purchase Confirmation ##{transaction.id}")
  end
end
