class Transaction < ApplicationRecord
  belongs_to :user
  has_many :transaction_items, dependent: :destroy
  has_many :products, through: :transaction_items

  enum :status, { success: 0, canceled: 1 }
  enum :payment_method, { qris: 0, cash: 1, transfer: 2 }
end
