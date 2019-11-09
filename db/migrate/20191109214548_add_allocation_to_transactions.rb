class AddAllocationToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :allocation, :string
    add_index :transactions, :allocation
  end
end
