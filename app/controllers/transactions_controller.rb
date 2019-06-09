class TransactionsController < ApplicationController
  before_action :load_plaid_items, only: :import
  before_action :import_accounts, only: :import

  def index
    @transactions = Transaction.includes(:account).order(date: :desc)

    if params[:account_type].present?
      @transactions = @transactions.where(accounts: { type: params[:account_type] })
    end

    if params[:allocation].present?
      @transactions = @transactions.where(accounts: { default_allocation: params[:allocation] })
    end

    @accounts = @transactions.map(&:account).uniq
  end

  def import
    start_date = params[:start_date]
    end_date = params[:end_date]

    @plaid_items.each do |plaid_item|
      transaction_response = PLAID_CLIENT.transactions.get(plaid_item.access_token, start_date, end_date)
      @transactions = transaction_response.transactions

      while @transactions.length < transaction_response['total_transactions']
        transaction_response = PLAID_CLIENT.transactions.get(plaid_item.access_token, start_date, end_date, offset: @transactions.length)
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
    end

    redirect_to transactions_path, notice: "Imported #{@transactions.length} transaction(s) from #{Account.count} account(s) and #{PlaidItem.count} institution(s)"
  end

  private

    def load_plaid_items
      @plaid_items = PlaidItem.all
    end

    def import_accounts
      @plaid_items.each do |plaid_item|
        accounts_response = PLAID_CLIENT.accounts.get(plaid_item.access_token)

        accounts_response.accounts.each do |account|
          Account.create_with(name: account.name).find_or_create_by(plaid_id: account.account_id)
        end
      end
    end
end
