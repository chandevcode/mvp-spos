class AddTenantToTransactionItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :transaction_items, :tenant, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        default_tenant = Tenant.first || Tenant.create!(name: "Default Tenant")
        TransactionItem.where(tenant_id: nil).update_all(tenant_id: default_tenant.id)
        change_column_null :transaction_items, :tenant_id, false
      end
    end
  end
end
