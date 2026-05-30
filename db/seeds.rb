# Clear existing data
TransactionItem.destroy_all
Transaction.destroy_all
Product.destroy_all
User.destroy_all

# Create users
owner = User.create!(
  email: "owner@spos.com",
  password: "password",
  role: :owner
)

admin = User.create!(
  email: "admin@spos.com",
  password: "password",
  role: :admin
)

puts "Created #{User.count} users"

# Create food products
foods = [
  { name: "Margherita Pizza", description: "Classic tomato and mozzarella", price: 12.99, category: :food },
  { name: "Cheeseburger", description: "Beef patty with cheese", price: 9.99, category: :food },
  { name: "Caesar Salad", description: "Fresh romaine with caesar dressing", price: 8.50, category: :food },
  { name: "Spaghetti Carbonara", description: "Creamy pasta with bacon", price: 14.99, category: :food },
  { name: "Chicken Wings", description: "Spicy buffalo wings", price: 11.99, category: :food },
  { name: "Fish & Chips", description: "Crispy battered fish", price: 13.50, category: :food },
  { name: "Tacos", description: "Three beef tacos", price: 10.99, category: :food },
  { name: "Pad Thai", description: "Thai stir-fried noodles", price: 12.50, category: :food }
]

# Create beverage products
beverages = [
  { name: "Coca Cola", description: "Classic soft drink", price: 2.99, category: :beverage },
  { name: "Orange Juice", description: "Fresh squeezed", price: 3.99, category: :beverage },
  { name: "Iced Coffee", description: "Cold brew coffee", price: 4.50, category: :beverage },
  { name: "Green Tea", description: "Hot or iced", price: 2.50, category: :beverage },
  { name: "Smoothie", description: "Mixed berry smoothie", price: 5.99, category: :beverage },
  { name: "Lemonade", description: "Fresh lemonade", price: 3.50, category: :beverage },
  { name: "Milkshake", description: "Chocolate milkshake", price: 5.50, category: :beverage },
  { name: "Mineral Water", description: "Sparkling water", price: 1.99, category: :beverage }
]

(foods + beverages).each do |product_data|
  Product.create!(product_data)
end

puts "Created #{Product.count} products"

# Create sample transactions
3.times do |i|
  transaction = admin.transactions.create!(
    total_price: rand(20.0..50.0).round(2),
    status: [:success, :canceled].sample
  )
  
  rand(2..4).times do
    product = Product.all.sample
    transaction.transaction_items.create!(
      product: product,
      quantity: rand(1..3),
      price: product.price
    )
  end
end

puts "Created #{Transaction.count} transactions"
puts "\nSeeding complete!"
puts "Login credentials:"
puts "Owner: owner@spos.com / password"
puts "Admin: admin@spos.com / password"
