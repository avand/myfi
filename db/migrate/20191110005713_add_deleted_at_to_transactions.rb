class AddDeletedAtToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :deleted_at, :datetime
  end
end
