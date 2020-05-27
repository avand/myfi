class ApplicationController < ActionController::Base
  before_action :load_expired_plaid_items

  private

  def load_expired_plaid_items
    @expired_plaid_items = PlaidItem.expired
  end
end
