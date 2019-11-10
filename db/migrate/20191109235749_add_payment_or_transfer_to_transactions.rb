class AddPaymentOrTransferToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payment_or_transfer, :boolean
  end
end
