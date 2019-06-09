class AddTypeToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :type, :string, index: true
  end
end
