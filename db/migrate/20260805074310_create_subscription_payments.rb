class CreateSubscriptionPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_payments do |t|
      t.string :email, null: false
      t.string :tenant_name
      t.string :plan_type, null: false # monthly or annual
      t.decimal :amount, precision: 12, scale: 0, null: false
      t.decimal :gross_amount, precision: 12, scale: 0
      t.integer :status, default: 0, null: false # enum: pending, success, failed, expired

      t.string :midtrans_order_id
      t.string :midtrans_transaction_id
      t.string :midtrans_status
      t.string :midtrans_payment_type
      t.string :snap_token
      t.string :snap_redirect_url
      t.string :password_digest

      t.references :tenant, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.datetime :transaction_time
      t.datetime :settlement_time
      t.datetime :expiry_time

      t.timestamps
    end

    add_index :subscription_payments, :midtrans_order_id, unique: true
  end
end
