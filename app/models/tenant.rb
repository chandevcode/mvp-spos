class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :transaction_items, dependent: :destroy

  validates :name, presence: true
end
