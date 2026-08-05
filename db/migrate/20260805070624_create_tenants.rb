class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain

      t.timestamps
    end

    add_index :tenants, :subdomain, unique: true
  end
end
