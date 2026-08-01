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
puts "Created #{User.count} users"
puts "Owner: owner@spos.com / password"
