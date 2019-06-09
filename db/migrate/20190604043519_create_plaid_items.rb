class CreatePlaidItems < ActiveRecord::Migration[5.2]
  def change
    create_table :plaid_items do |t|
      t.string :item_id
      t.string :access_token

      t.timestamps
    end
  end
end
