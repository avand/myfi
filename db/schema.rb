# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_09_214012) do

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "plaid_id"
    t.string "type"
    t.string "default_allocation"
  end

  create_table "plaid_items", force: :cascade do |t|
    t.string "item_id"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "plaid_account_id"
    t.decimal "amount", precision: 8, scale: 2
    t.string "date"
    t.string "name"
    t.string "plaid_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
