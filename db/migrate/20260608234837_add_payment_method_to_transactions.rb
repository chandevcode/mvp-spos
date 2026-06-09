class AddPaymentMethodToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :payment_method, :integer
  end
end
