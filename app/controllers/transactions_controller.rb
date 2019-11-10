require 'csv'

class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.includes(:account).order(date: :desc)
    @types = Account.all.map(&:type).uniq.sort

    if params[:filters].present?
      if params[:filters][:scope] == 'unallocated'
        @transactions = @transactions.where(allocation: nil)
      end

      if params[:filters][:scope] == 'unsettled'
        @transactions = @transactions.where(settled_at: nil)
      end

      if params[:filters][:account_id].present?
        @transactions = @transactions.where(accounts: { id: params[:filters][:account_id] })
      end

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

    if !params[:filters] || params[:filters][:include_payments_and_transfers].blank?
      @transactions = @transactions.where(payment_or_transfer: [nil, false])
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
    @accounts = Account.all

    @accounts.find_each do |account|
      plaid_item = account.plaid_item
      transaction_response = PLAID_CLIENT.transactions.get(plaid_item.access_token, start_date, end_date, account_ids: [account.plaid_id])

      transactions = transaction_response.transactions.select { |t| !t.pending }

      while transactions.length < transaction_response.total_transactions
        transaction_response = PLAID_CLIENT.transactions.get(plaid_item.access_token, start_date, end_date, offset: transactions.length)
        transactions += transaction_response.transactions
      end

      transactions.each do |transaction|
        record = account.transactions.find_or_initialize_by({
          amount: transaction.amount,
          date: transaction.date,
          name: transaction.name,
        })

        record.plaid_account_id = transaction.account_id
        record.plaid_transaction_id = transaction.transaction_id

        if record.new_record?
          @new_transactions << record
        else
          record.occurrences += 1 if record.plaid_transaction_id_changed?
        end

        record.save
      end
    end

    redirect_to transactions_path, notice: "Imported #{@new_transactions.length} new transaction(s) from #{@accounts.count} account(s)."
  end

  def update
    transaction = Transaction.find(params[:id])

    transaction.update(transaction_params)

    render partial: 'form', locals: { transaction: transaction }, layout: false
  end

  private

  def transaction_params
    params.require(:transaction).permit(:allocation, :payment_or_transfer)
  end
end
