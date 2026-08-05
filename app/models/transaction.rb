class Transaction < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :user
  has_many :transaction_items, dependent: :destroy
  has_many :products, through: :transaction_items

  enum :status, { success: 0, canceled: 1 }
  enum :payment_method, { qris: 0, cash: 1, transfer: 2 }

  after_create :decrement_stock!
  after_update :handle_stock_restore!, if: -> { saved_change_to_status? && canceled? }

  private

  def decrement_stock!
    transaction_items.each do |item|
      product = item.product
      new_stock = [ product.stock_quantity - item.quantity, 0 ].max
      product.update!(stock_quantity: new_stock)
    end
  end

  def handle_stock_restore!
    transaction_items.each do |item|
      product = item.product
      product.increment!(:stock_quantity, item.quantity)
    end
  end
end
