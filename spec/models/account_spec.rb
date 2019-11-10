require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'get_transactions_from_plaid' do
    let(:plaid_item) { PlaidItem.create(access_token: 'access_token') }
    let(:account) { Account.create(plaid_item: plaid_item, plaid_id: 'plaid_id') }

    it 'gets transactions from Plaid for the account' do
      response = double.tap do |response|
        allow(response).to receive(:transactions).and_return(['transaction'])
        allow(response).to receive(:total_transactions).and_return(1)
      end

      expect(PLAID_CLIENT.transactions).to receive(:get).with(
        plaid_item.access_token,
        '2019-11-08',
        '2019-11-09',
        { offset: 0, count: 1, account_ids: [account.plaid_id] },
      ).and_return(response)

      transactions = account.get_transactions_from_plaid('2019-11-08', '2019-11-09', count: 1)

      expect(transactions).to eq(['transaction'])
    end

    it 'makes multiple requests to get all results' do
      response_1 = double.tap do |response|
        allow(response).to receive(:transactions).and_return(['transaction_1'])
        allow(response).to receive(:total_transactions).and_return(2)
      end

      response_2 = double.tap do |response|
        allow(response).to receive(:transactions).and_return(['transaction_2'])
        allow(response).to receive(:total_transactions).and_return(2)
      end

      expect(PLAID_CLIENT.transactions).to receive(:get).with(
        plaid_item.access_token,
        '2019-11-08',
        '2019-11-09',
        { offset: 0, count: 2, account_ids: [account.plaid_id] },
      ).and_return(response_1).ordered

      expect(PLAID_CLIENT.transactions).to receive(:get).with(
        plaid_item.access_token,
        '2019-11-08',
        '2019-11-09',
        { offset: 1, count: 2, account_ids: [account.plaid_id] },
      ).and_return(response_2).ordered

      transactions = account.get_transactions_from_plaid('2019-11-08', '2019-11-09', count: 2)

      expect(transactions).to eq(['transaction_1', 'transaction_2'])
    end
  end
end
