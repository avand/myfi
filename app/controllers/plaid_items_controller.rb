class PlaidItemsController < ApplicationController
  include ActionView::Helpers::DateHelper

  skip_before_action :verify_authenticity_token

  def create
    exchange = PLAID_CLIENT.item.public_token.exchange(params[:public_token])
    access_token = exchange.access_token

    item = PLAID_CLIENT.item.get(access_token).item
    accounts = PLAID_CLIENT.accounts.get(access_token).accounts
    institution = PLAID_CLIENT.institutions.get_by_id(item.institution_id).institution

    plaid_item = PlaidItem.create_with({
      item_id: item.item_id,
      access_token: access_token,
    }).find_or_create_by({
      institution_name: institution.name,
      institution_id: institution.institution_id,
    })

    accounts = accounts.map do |account|
      record = Account.find_or_initialize_by({ mask: account.mask, plaid_item_id: plaid_item.id })

      record.name = account.name
      record.plaid_id = account.account_id
      record.type = account.type
      record.official_name = account.official_name

      record.save

      record
    end

    redirect_to accounts_path, notice: "Linked #{plaid_item.institution_name} (created #{time_ago_in_words plaid_item.created_at} ago) and updated #{accounts.size} account(s)."
  end
end
