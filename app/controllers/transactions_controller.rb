class TransactionsController < ApplicationController
  before_action :import_accounts, only: :import

  def index
    @transactions = Transaction.includes(:account).all
  end

  def import
    start_date = params[:start_date]
    end_date = params[:end_date]

    transaction_response = plaid_client.transactions.get(plaid_item.access_token, start_date, end_date)
    @transactions = transaction_response.transactions

    # the transactions in the response are paginated, so make multiple calls while
    # increasing the offset to retrieve all transactions
    while @transactions.length < transaction_response['total_transactions']
      transaction_response = plaid_client.transactions.get(plaid_item.access_token, start_date, end_date, offset: @transactions.length)
      @transactions += transaction_response.transactions
    end

    @transactions.each do |transaction|
      account = Account.find_by(plaid_id: transaction.account_id)

      account.transactions.create_with({
        plaid_account_id: transaction.account_id,
        account_id: account.id,
        amount: transaction.amount,
        name: transaction.name,
        date: transaction.date,
      }).find_or_create_by(plaid_transaction_id: transaction.transaction_id)
    end

    redirect_to transactions_path
  end

  private

    def import_accounts
      accounts_response = plaid_client.accounts.get(plaid_item.access_token)

      accounts_response.accounts.each do |account|
        Account.create_with(name: account.official_name).find_or_create_by(plaid_id: account.account_id)
      end
    end

    def plaid_item
      @plaid_item ||= PlaidItem.last
    end
end
