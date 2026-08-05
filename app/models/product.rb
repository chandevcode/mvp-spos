class Product < ApplicationRecord
  acts_as_tenant(:tenant)

  has_one_attached :image

  enum :category, { food: 0, beverage: 1 }

  validates :name, presence: true, length: { maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :in_stock, -> { where("stock_quantity > 0") }
  scope :out_of_stock, -> { where(stock_quantity: 0) }
  scope :low_stock, -> { where("stock_quantity > 0 AND stock_quantity <= ?", 5) }

  def in_stock?
    stock_quantity > 0
  end

  def low_stock?
    stock_quantity > 0 && stock_quantity <= 5
  end

  def out_of_stock?
    stock_quantity <= 0
  end

  def stock_level
    if out_of_stock?
      :out
    elsif low_stock?
      :low
    else
      :ok
    end
  end
end
