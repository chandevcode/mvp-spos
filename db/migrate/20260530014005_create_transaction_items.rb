class CreateTransactionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :transaction_items do |t|
      t.references :transaction, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end
  end
end
