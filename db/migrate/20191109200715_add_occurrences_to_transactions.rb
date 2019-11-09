class AddOccurrencesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :occurrences, :integer, default: 1, null: false
  end
end
