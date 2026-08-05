class AddTenantToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :tenant, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        default_tenant = Tenant.first || Tenant.create!(name: "Default Tenant")
        User.where(tenant_id: nil).update_all(tenant_id: default_tenant.id)
        change_column_null :users, :tenant_id, false
      end
    end
  end
end
