require 'csv'

class TransactionsController < ApplicationController
  before_action :load_plaid_items, only: :import
  before_action :import_accounts, only: :import

  def index
    @transactions = Transaction.includes(:account).order(date: :desc)

    if params[:filters].present?
      if params[:filters][:account_type].present?
        @transactions = @transactions.where(accounts: { type: params[:filters][:account_type] })
      end

      if params[:filters][:allocation].present?
        @transactions = @transactions.where(accounts: { default_allocation: params[:filters][:allocation] })
      end

      if params[:filters][:start_date].present?
        @transactions = @transactions.where('date >= ?', params[:filters][:start_date])
      end

      if params[:filters][:end_date].present?
        @transactions = @transactions.where('date < ?', params[:filters][:end_date])
      end
    end

    respond_to do |format|
      format.html
      format.csv do
        csv = CSV.generate(headers: true) do |csv|
          csv << %w(date description amount account default_allocation year_month)

          @transactions.each do |transaction|
            csv << [
              transaction.date,
              transaction.name,
              transaction.amount,
              transaction.account.name,
              transaction.account.default_allocation,
              transaction.year_month,
            ]
          end
        end

        send_data csv, filename: 'transactions.csv'
      end
    end
  end

  def import
    start_date = params[:start_date]
    end_date = params[:end_date]
    @new_transactions = []

    @plaid_items.each do |plaid_item|
      transaction_response = PLAID_CLIENT.transactions.get(plaid_item.access_token, start_date, end_date)
      @transactions = transaction_response.transactions.select { |t| !t.pending }

      while @transactions.length < transaction_response['total_transactions']
        transaction_response = PLAID_CLIENT.transactions.get(plaid_item.access_token, start_date, end_date, offset: @transactions.length)
        @transactions += transaction_response.transactions
      end

      @transactions.each do |transaction|
        account = Account.find_by(plaid_id: transaction.account_id)
        existing_transaction = Transaction.find_by(plaid_transaction_id: transaction.transaction_id)

        if existing_transaction.blank?
          @new_transactions << account.transactions.create({
            account_id: account.id,
            amount: transaction.amount,
            date: transaction.date,
            name: transaction.name,
            plaid_account_id: transaction.account_id,
            plaid_transaction_id: transaction.transaction_id,
          })
        end
      end
    end

    redirect_to transactions_path, notice: "Imported #{@new_transactions.length} new transaction(s) from #{Account.count} account(s) and #{PlaidItem.count} institution(s)"
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
