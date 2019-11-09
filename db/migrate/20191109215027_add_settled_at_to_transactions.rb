class AddSettledAtToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :settled_at, :datetime
  end
end
