class Product < ApplicationRecord
  enum :category, { food: 0, beverage: 1 }
end
