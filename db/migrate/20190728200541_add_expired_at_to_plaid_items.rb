class AddExpiredAtToPlaidItems < ActiveRecord::Migration[5.2]
  def change
    add_column :plaid_items, :expired_at, :datetime
  end
end
