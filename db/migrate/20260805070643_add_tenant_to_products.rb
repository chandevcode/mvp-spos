class AddTenantToProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :products, :tenant, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        default_tenant = Tenant.first || Tenant.create!(name: "Default Tenant")
        Product.where(tenant_id: nil).update_all(tenant_id: default_tenant.id)
        change_column_null :products, :tenant_id, false
      end
    end
  end
end
