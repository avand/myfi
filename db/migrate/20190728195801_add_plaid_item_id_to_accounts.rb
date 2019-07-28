class AddPlaidItemIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :plaid_item_id, :integer
  end
end
