class PlaidItemsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    exchange = PLAID_CLIENT.item.public_token.exchange(params[:public_token])

    PlaidItem.create item_id: exchange.item_id, access_token: exchange.access_token

    redirect_to transactions_path
  end
end
