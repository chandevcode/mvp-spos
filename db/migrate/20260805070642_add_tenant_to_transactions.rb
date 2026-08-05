class AddTenantToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_reference :transactions, :tenant, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        default_tenant = Tenant.first || Tenant.create!(name: "Default Tenant")
        Transaction.where(tenant_id: nil).update_all(tenant_id: default_tenant.id)
        change_column_null :transactions, :tenant_id, false
      end
    end
  end
end
