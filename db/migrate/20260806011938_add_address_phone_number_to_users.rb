class AddAddressPhoneNumberToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :address, :string
    add_column :users, :phone_number, :string
  end
end
