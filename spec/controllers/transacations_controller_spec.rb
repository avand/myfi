require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'import' do
    let!(:plaid_item) do
      PlaidItem.create({
        item_id: 'item_id',
        access_token: 'access_token',
        institution_name: 'Institution Name',
        institution_id: 'institution_id',
      })
    end

    let!(:account) do
      Account.create({
        name: 'Account Name',
        plaid_id: 'plaid_id',
        type: 'credit',
        default_allocation: Account::ALLOCATION_LIFESTYLE,
        plaid_item_id: plaid_item.id,
        official_name: 'Official Name',
        mask: 'mask',
      })
    end

    let(:plaid_client_transaction) do
      double.tap do |transaction|
        allow(transaction).to receive(:pending).and_return(false)
        allow(transaction).to receive(:transaction_id).and_return('transaction_id')
        allow(transaction).to receive(:amount).and_return(1.23)
        allow(transaction).to receive(:date).and_return('2019-01-24')
        allow(transaction).to receive(:name).and_return('Transaction Name')
        allow(transaction).to receive(:account_id).and_return('account_id')
      end
    end

    let(:plaid_client_transaction_response) do
      double.tap do |response|
        allow(response).to receive(:transactions).and_return([plaid_client_transaction])
        allow(response).to receive(:total_transactions).and_return(1)
      end
    end

    before do
      allow(PLAID_CLIENT.transactions).to receive(:get).and_return(plaid_client_transaction_response)
    end

    it 'creates a Transaction' do
      expect { post :import }.to change { Transaction.count }.by(1)

      Transaction.last.tap do |transaction|
        expect(transaction.plaid_transaction_id).to eq(plaid_client_transaction.transaction_id)
        expect(transaction.amount).to eq(plaid_client_transaction.amount)
        expect(transaction.name).to eq(plaid_client_transaction.name)
        expect(transaction.plaid_account_id).to eq(plaid_client_transaction.account_id)
        expect(transaction.account_id).to eq(account.id)
      end
    end

    it 'updates an existing Transaction based on account, date, name, and amount' do
      transaction = Transaction.create({
        account_id: account.id,
        date: plaid_client_transaction.date,
        name: plaid_client_transaction.name,
        amount: plaid_client_transaction.amount,
      })

      expect { post :import }.to change { Transaction.count }.by(0)
      expect(transaction.reload.occurrences).to eq(2)
    end

    it 'redirects to transactions_path' do
      post :import

      expect(response).to redirect_to(transactions_path)
    end
  end
end
