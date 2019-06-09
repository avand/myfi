class AddUserIdToPlaidItems < ActiveRecord::Migration[5.2]
  def change
    add_column :plaid_items, :user_id, :integer, index: true
  end
end
