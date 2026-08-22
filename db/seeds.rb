# frozen_string_literal: true

puts "🌱 Seeding database..."

# Clear existing data (order matters for foreign keys)
TransactionItem.destroy_all
Transaction.destroy_all
SubscriptionPayment.destroy_all
Product.destroy_all
User.destroy_all
Tenant.destroy_all

# ============================================================================
# Tenants
# ============================================================================
tenants_data = [
  { name: "Warung Bahari", subdomain: "warung-bahari" },
  { name: "Kedai Kopi Senja", subdomain: "kedai-senja" },
  { name: "RM Padang Sederhana", subdomain: "padang-sederhana" }
]

tenants = tenants_data.map do |data|
  t = Tenant.create!(
    name: data[:name],
    subdomain: data[:subdomain],
    subscription_status: :active,
    subscription_plan: "monthly",
    subscribed_at: Time.current,
    subscription_expires_at: 1.month.from_now
  )
  puts "  ✓ Tenant: #{t.name}"
  t
end

# ============================================================================
# Users
# ============================================================================

users_data = [
  # Tenant 1: Warung Bahari
  { tenant: tenants[0], email: "owner@warungbahari.com",  password: "password", name: "Bambang Supriyadi",  address: "Jl. Melati No. 10, Jakarta",      phone_number: "0812-3456-7890", role: :owner },
  { tenant: tenants[0], email: "admin@warungbahari.com",  password: "password", name: "Siti Nurhaliza",     address: "Jl. Kenanga No. 22, Jakarta",     phone_number: "0813-9876-5432", role: :admin },
  { tenant: tenants[0], email: "kasir@warungbahari.com",  password: "password", name: "Ahmad Rizki",        address: "Jl. Mawar No. 5, Jakarta",        phone_number: "0856-1112-3344", role: :admin },

  # Tenant 2: Kedai Kopi Senja
  { tenant: tenants[1], email: "owner@kedaikopi.com",     password: "password", name: "Dian Permatasari",   address: "Jl. Sunset Blvd No. 88, Bandung", phone_number: "0821-5544-3322", role: :owner },
  { tenant: tenants[1], email: "admin@kedaikopi.com",     password: "password", name: "Rudi Hartono",       address: "Jl. Diponegoro No. 15, Bandung",  phone_number: "0878-9988-7766", role: :admin },

  # Tenant 3: RM Padang Sederhana
  { tenant: tenants[2], email: "owner@padangsederhana.com", password: "password", name: "Zulkifli Abdullah", address: "Jl. Nusantara No. 7, Padang",   phone_number: "0752-3344-5566", role: :owner },
  { tenant: tenants[2], email: "admin@padangsederhana.com", password: "password", name: "Fitry Yani",        address: "Jl. Khatib Sulaiman No. 3, Padang", phone_number: "0752-7788-9900", role: :admin }
]

users = users_data.map do |data|
  u = User.create!(
    email: data[:email],
    password: data[:password],
    name: data[:name],
    address: data[:address],
    phone_number: data[:phone_number],
    role: data[:role],
    tenant: data[:tenant]
  )
  role_label = data[:role] == :owner ? "🟢 Owner" : "🔵 Admin"
  puts "  #{role_label}: #{u.name} (#{u.email}) — #{data[:tenant].name}"
  u
end

puts "  ✅ #{User.count} users created"

# ============================================================================
# Products — Warung Bahari (Indonesian home-style food)
# ============================================================================
warung_products = [
  # Foods
  { name: "Nasi Goreng",        description: "Nasi goreng spesial dengan telur, ayam suwir, dan kerupuk",              price: 25_000,  stock: 30, category: :food },
  { name: "Mie Goreng",        description: "Mie goreng spesial dengan telur dan sayuran segar",                      price: 22_000,  stock: 25, category: :food },
  { name: "Ayam Bakar",        description: "Ayam bakar bumbu kecap dengan lalapan dan sambal",                        price: 35_000,  stock: 15, category: :food },
  { name: "Ayam Goreng",       description: "Ayam goreng tepung crispy dengan sambal terasi",                          price: 30_000,  stock: 20, category: :food },
  { name: "Sate Ayam",         description: "10 tusuk sate ayam dengan bumbu kacang dan lontong",                      price: 28_000,  stock: 18, category: :food },
  { name: "Capcay Goreng",     description: "Capcay goreng sayuran segar dengan udang dan bakso",                      price: 24_000,  stock: 22, category: :food },
  { name: "Bakso Malang",      description: "Bakso sapi kenyal dengan mie, pangsit, dan kuah kaldu",                   price: 20_000,  stock: 40, category: :food },
  { name: "Pecel Lele",        description: "Lele goreng garing dengan pecel sayur dan sambal",                        price: 18_000,  stock: 12, category: :food },
  { name: "Nasi Kuning",       description: "Nasi kuning lengkap dengan lauk pauk dan sambal goreng kentang",          price: 27_000,  stock: 10, category: :food },
  { name: "Tahu Telor",        description: "Tahu telor dadar dengan kecap manis dan acar timun",                      price: 16_000,  stock: 15, category: :food },

  # Beverages
  { name: "Es Teh Manis",      description: "Teh manis segar dengan es batu",                                          price: 5_000,   stock: 100, category: :beverage },
  { name: "Es Jeruk",          description: "Jeruk peras segar dengan es batu",                                        price: 7_000,   stock: 80,  category: :beverage },
  { name: "Kopi Hitam",        description: "Kopi hitam tubruk khas Indonesia",                                        price: 8_000,   stock: 50,  category: :beverage },
  { name: "Susu Jahe",         description: "Susu hangat dengan jahe segar dan gula merah",                             price: 10_000,  stock: 30,  category: :beverage },
  { name: "Air Mineral",       description: "Air mineral kemasan 600ml",                                               price: 4_000,   stock: 200, category: :beverage },
  { name: "Jus Alpukat",       description: "Jus alpukat segar dengan susu kental manis dan cokelat",                   price: 12_000,  stock: 20,  category: :beverage }
]

# ============================================================================
# Products — Kedai Kopi Senja (Coffee shop with light bites)
# ============================================================================
kedai_products = [
  # Foods
  { name: "Croissant",         description: "Croissant panggang mentega dengan isian pilihan",                          price: 22_000,  stock: 10, category: :food },
  { name: "Sandwich Club",     description: "Sandwich roti tawar lapis ayam, selada, tomat, dan mayo",                  price: 28_000,  stock: 12, category: :food },
  { name: "Pasta Aglio Olio",  description: "Spaghetti aglio olio dengan udang dan cabai kering",                       price: 35_000,  stock: 8,  category: :food },
  { name: "French Fries",      description: "Kentang goreng crispy dengan saus sambal dan keju",                        price: 18_000,  stock: 20, category: :food },
  { name: "Banana Pancake",   description: "Pancake pisang dengan madu dan taburan kacang almond",                      price: 25_000,  stock: 6,  category: :food },

  # Beverages
  { name: "Espresso",          description: "Single shot espresso klasik",                                              price: 18_000,  stock: 50,  category: :beverage },
  { name: "Cappuccino",        description: "Kopi cappuccino dengan foam susu lembut",                                  price: 28_000,  stock: 40,  category: :beverage },
  { name: "Latte",             description: "Kopi latte dengan steamed milk",                                            price: 30_000,  stock: 40,  category: :beverage },
  { name: "Mocha",             description: "Perpaduan espresso dengan cokelat dan susu segar",                          price: 33_000,  stock: 35,  category: :beverage },
  { name: "Cold Brew",         description: "Cold brew 12 jam ekstraksi, smooth dan low acid",                           price: 35_000,  stock: 20,  category: :beverage },
  { name: "Matcha Latte",      description: "Matcha premium dengan susu segar pilihan",                                 price: 32_000,  stock: 25,  category: :beverage },
  { name: "Chocolate Frappe",  description: "Minuman cokelat dingin blend dengan whipped cream",                          price: 38_000,  stock: 15,  category: :beverage },
  { name: "Green Tea",         description: "Teh hijau Jepang segar",                                                   price: 15_000,  stock: 30,  category: :beverage }
]

# ============================================================================
# Products — RM Padang Sederhana (Padang restaurant)
# ============================================================================
padang_products = [
  # Foods
  { name: "Rendang",           description: "Rendang sapi asli Padang, dimasak 4 jam dengan 15 rempah",                  price: 40_000,  stock: 20, category: :food },
  { name: "Ayam Pop",          description: "Ayam pop khas Padang dengan sambal hijau dan daun singkong",                price: 28_000,  stock: 15, category: :food },
  { name: "Dendeng Batokok",   description: "Dendeng daging sapi pipih dengan sambal lado ijo",                         price: 35_000,  stock: 10, category: :food },
  { name: "Gulai Cincang",     description: "Gulai daging cincang khas Padang dengan kuah santan kuning",                price: 30_000,  stock: 12, category: :food },
  { name: "Sate Padang",       description: "Sate daging dan jeroan dengan kuah gulai kental dan lontong",               price: 32_000,  stock: 18, category: :food },
  { name: "Ikan Bilih Goreng", description: "Ikan bilih goreng crispy dari Danau Singkarak",                             price: 22_000,  stock: 14, category: :food },
  { name: "Perkedel Kentang",  description: "Perkedel kentang khas Padang dengan campuran daging cincang",               price: 5_000,   stock: 30, category: :food },
  { name: "Daun Singkong",     description: "Daun singkong rebus dengan santan dan cabe",                                price: 8_000,   stock: 25, category: :food },

  # Beverages
  { name: "Teh Talua",         description: "Teh hangat khas Padang dengan campuran kuning telur",                       price: 10_000,  stock: 20, category: :beverage },
  { name: "Es Kopyor",         description: "Es kelapa kopyor segar dengan sirup merah",                                 price: 12_000,  stock: 15, category: :beverage },
  { name: "Sari Asam",         description: "Minuman asam segar khas Minang",                                         price: 8_000,   stock: 25, category: :beverage },
  { name: "Teh Hangat",        description: "Teh hangat untuk menemani santapan",                                        price: 4_000,   stock: 50, category: :beverage },
  { name: "Es Teh Manis",      description: "Teh manis dingin dengan es batu",                                           price: 5_000,   stock: 60, category: :beverage }
]

# Create all products
all_products = []

products_by_tenant = {
  tenants[0] => warung_products,
  tenants[1] => kedai_products,
  tenants[2] => padang_products
}

products_by_tenant.each do |tenant, products_data|
  products_data.each do |data|
    p = Product.create!(
      name: data[:name],
      description: data[:description],
      price: data[:price],
      stock_quantity: data[:stock],
      category: data[:category],
      tenant: tenant
    )
    all_products << p
    puts "  🍽️  #{p.name} — Rp #{p.price.to_i.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1.')} (#{p.stock_quantity} pcs) — #{tenant.name}"
  end
end

puts "  ✅ #{Product.count} products created"

# ============================================================================
# Sample Transactions
# ============================================================================
# Create a few completed transactions for each tenant with today's date

today = Date.current
tenants.each do |tenant|
  tenant_products = Product.where(tenant: tenant)
  next if tenant_products.empty?

  # Create 3-5 random transactions per tenant
  rand(3..5).times do |i|
    # Pick 1-4 random items
    items_count = rand(1..4)
    selected_products = tenant_products.sample(items_count)

    transaction = Transaction.new(
      status: :success,
      payment_method: [ :cash, :cash, :cash, :qris, :transfer ].sample,
      user: tenant.users.first,
      tenant: tenant,
      created_at: today - i.hours  # Spread across today
    )

    total = 0
    transaction_items = selected_products.map do |product|
      qty = rand(1..3)
      price = product.price * qty
      total += price
      { product: product, quantity: qty, price: product.price, tenant: tenant }
    end

    transaction.total_price = total
    transaction.save!

    transaction_items.each do |item_data|
      TransactionItem.create!(
        transaction_id: transaction.id,
        product: item_data[:product],
        quantity: item_data[:quantity],
        price: item_data[:price],
        tenant: item_data[:tenant]
      )
    end

    item_names = selected_products.map(&:name).join(", ")
    puts "  💰 #{transaction.payment_method&.titleize} — #{item_names} (Rp #{total.to_i.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1.')}) — #{tenant.name}"
  end
end

puts "  ✅ #{Transaction.count} transactions created"
puts ""
puts "🎉 Seeding complete!"
puts ""
puts "=" * 50
puts "LOGIN CREDENTIALS"
puts "=" * 50
puts ""
puts "Warung Bahari:"
puts "  🟢 Owner: owner@warungbahari.com / password"
puts "  🔵 Admin: admin@warungbahari.com / password"
puts "  🔵 Kasir:  kasir@warungbahari.com / password"
puts ""
puts "Kedai Kopi Senja:"
puts "  🟢 Owner: owner@kedaikopi.com / password"
puts "  🔵 Admin: admin@kedaikopi.com / password"
puts ""
puts "RM Padang Sederhana:"
puts "  🟢 Owner: owner@padangsederhana.com / password"
puts "  🔵 Admin: admin@padangsederhana.com / password"
puts ""
puts "=" * 50
