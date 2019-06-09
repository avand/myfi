class AddDefaultAllocationToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :default_allocation, :string, index: true
  end
end
