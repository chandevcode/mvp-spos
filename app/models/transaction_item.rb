class TransactionItem < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :order, class_name: "Transaction", foreign_key: "transaction_id"
  belongs_to :product
end
