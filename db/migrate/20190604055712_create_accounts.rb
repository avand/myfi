class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :plaid_id
    end

    add_column :transactions, :account_id, :integer, index: true
  end
end
