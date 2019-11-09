class AddInstitutionToPlaidItems < ActiveRecord::Migration[5.2]
  def change
    add_column :plaid_items, :institution, :string
  end
end
