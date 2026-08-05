# Clear existing data
TransactionItem.destroy_all
Transaction.destroy_all
Product.destroy_all
User.destroy_all
Tenant.destroy_all

# Create default tenant
tenant = Tenant.create!(
  name: "Default Store",
  subdomain: "default"
)
puts "Created tenant: #{tenant.name}"

# Create users within the tenant
owner = User.create!(
  email: "owner@spos.com",
  password: "password",
  role: :owner,
  tenant: tenant
)

admin = User.create!(
  email: "admin@spos.com",
  password: "password",
  role: :admin,
  tenant: tenant
)

puts "Created #{User.count} users"
puts "Owner: owner@spos.com / password"
puts "Admin: admin@spos.com / password"
