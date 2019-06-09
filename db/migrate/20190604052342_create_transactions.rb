class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :plaid_account_id
      t.decimal :amount, precision: 8, scale: 2
      t.string :date
      t.string :name
      t.string :plaid_transaction_id

      t.timestamps
    end
  end
end
