class AccountsController < ApplicationController
  before_action :load_account, only: [:edit, :update]

  def index
    @accounts = Account.order(:name).includes(:plaid_item)
  end

  def edit
  end

  def update
    @account.update account_params

    redirect_to accounts_path, notice: 'Account updated'
  end

  private

    def load_account
      @account = Account.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:name, :type, :default_allocation, :plaid_item_id)
    end
end
