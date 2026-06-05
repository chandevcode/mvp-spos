class Product < ApplicationRecord
  has_one_attached :image

  enum :category, { food: 0, beverage: 1 }
end
