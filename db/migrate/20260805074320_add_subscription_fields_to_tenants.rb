class AddSubscriptionFieldsToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :subscription_status, :integer, default: 0, null: false
    add_column :tenants, :subscription_plan, :string
    add_column :tenants, :subscribed_at, :datetime
    add_column :tenants, :subscription_expires_at, :datetime
  end
end
