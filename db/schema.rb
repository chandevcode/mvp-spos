# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_06_011942) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.integer "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.decimal "price"
    t.integer "stock_quantity", default: 0, null: false
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_products_on_tenant_id"
  end

  create_table "subscription_payments", force: :cascade do |t|
    t.string "address"
    t.decimal "amount", precision: 12, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expiry_time"
    t.decimal "gross_amount", precision: 12
    t.string "midtrans_order_id"
    t.string "midtrans_payment_type"
    t.string "midtrans_status"
    t.string "midtrans_transaction_id"
    t.string "name"
    t.string "password_digest"
    t.string "phone_number"
    t.string "plan_type", null: false
    t.datetime "settlement_time"
    t.string "snap_redirect_url"
    t.string "snap_token"
    t.integer "status", default: 0, null: false
    t.integer "tenant_id"
    t.string "tenant_name"
    t.datetime "transaction_time"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["midtrans_order_id"], name: "index_subscription_payments_on_midtrans_order_id", unique: true
    t.index ["tenant_id"], name: "index_subscription_payments_on_tenant_id"
    t.index ["user_id"], name: "index_subscription_payments_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "subdomain"
    t.datetime "subscribed_at"
    t.datetime "subscription_expires_at"
    t.string "subscription_plan"
    t.integer "subscription_status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "transaction_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "price"
    t.integer "product_id", null: false
    t.integer "quantity"
    t.integer "tenant_id", null: false
    t.integer "transaction_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_transaction_items_on_product_id"
    t.index ["tenant_id"], name: "index_transaction_items_on_tenant_id"
    t.index ["transaction_id"], name: "index_transaction_items_on_transaction_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "payment_method"
    t.integer "status"
    t.integer "tenant_id", null: false
    t.decimal "total_price"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tenant_id"], name: "index_transactions_on_tenant_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "products", "tenants"
  add_foreign_key "subscription_payments", "tenants"
  add_foreign_key "subscription_payments", "users"
  add_foreign_key "transaction_items", "products"
  add_foreign_key "transaction_items", "tenants"
  add_foreign_key "transaction_items", "transactions"
  add_foreign_key "transactions", "tenants"
  add_foreign_key "transactions", "users"
  add_foreign_key "users", "tenants"
end
