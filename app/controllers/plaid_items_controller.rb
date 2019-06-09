class PlaidItemsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end

  def create
    exchange = plaid_client.item.public_token.exchange(params[:public_token])

    PlaidItem.create item_id: exchange.item_id, access_token: exchange.access_token

    redirect_to transactions_path
  end
end
