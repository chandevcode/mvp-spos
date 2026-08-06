class AddNameAddressPhoneNumberToSubscriptionPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :subscription_payments, :name, :string
    add_column :subscription_payments, :address, :string
    add_column :subscription_payments, :phone_number, :string
  end
end
