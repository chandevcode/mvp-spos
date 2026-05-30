class TransactionItem < ApplicationRecord
  belongs_to :transaction
  belongs_to :product
end
