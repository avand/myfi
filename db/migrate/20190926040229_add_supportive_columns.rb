class AddSupportiveColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :plaid_items, :institution, :institution_name
    add_column :plaid_items, :institution_id, :string
    add_column :accounts, :official_name, :string
    add_column :accounts, :mask, :string
  end
end
