require 'rails_helper'

RSpec.describe PlaidItemsController, type: :controller do
  describe 'create' do
    let(:access_token) { 'abc123' }

    let(:plaid_client_item) do
      item = double

      allow(item).to receive(:item_id).and_return('plaid_item_123')
      allow(item).to receive(:institution_id).and_return('ins_1')

      item
    end

    let(:plaid_client_account) do
      account = double

      allow(account).to receive(:mask).and_return('1234')
      allow(account).to receive(:name).and_return('Account Name')
      allow(account).to receive(:account_id).and_return('abc123def456')
      allow(account).to receive(:type).and_return('credit')
      allow(account).to receive(:official_name).and_return('Official Name')

      account
    end

    let(:plaid_client_institution) do
      institution = double

      allow(institution).to receive(:institution_id).and_return(plaid_client_item.institution_id)
      allow(institution).to receive(:name).and_return('Institution Name')

      institution
    end

    let(:existing_plaid_item) do
      PlaidItem.create({
        institution_id: plaid_client_institution.institution_id,
        institution_name: plaid_client_institution.name,
      })
    end

    before do
      allow(PLAID_CLIENT.item).to \
        receive_message_chain(:public_token, :exchange, :access_token)
        .and_return(access_token)

      allow(PLAID_CLIENT.item).to receive_message_chain(:get, :item).and_return(plaid_client_item)
      allow(PLAID_CLIENT.accounts).to receive_message_chain(:get, :accounts).and_return([plaid_client_account])
      allow(PLAID_CLIENT.institutions).to receive_message_chain(:get_by_id, :institution).and_return(plaid_client_institution)
    end

    it 'creates a PlaidItem' do
      expect { post :create }.to change { PlaidItem.count }.by(1)

      PlaidItem.last.tap do |plaid_item|
        expect(plaid_item.item_id).to eq(plaid_client_item.item_id)
        expect(plaid_item.access_token).to eq(access_token)
        expect(plaid_item.institution_name).to eq(plaid_client_institution.name)
        expect(plaid_item.institution_id).to eq(plaid_client_institution.institution_id)
      end
    end

    it 'finds an existing PlaidItem based on institution name and ID' do
      existing_plaid_item

      expect { post :create }.to change { PlaidItem.count }.by(0)
    end

    it 'creates an Account' do
      expect { post :create }.to change { Account.count }.by(1)

      Account.last.tap do |account|
        expect(account.mask).to eq(plaid_client_account.mask)
        expect(account.name).to eq(plaid_client_account.name)
        expect(account.plaid_id).to eq(plaid_client_account.account_id)
        expect(account.type).to eq(plaid_client_account.type)
        expect(account.official_name).to eq(plaid_client_account.official_name)
        expect(account.plaid_item_id).to eq(PlaidItem.last.id)
      end
    end

    it 'updates an existing Account based on mask and PlaidItem#id' do
      account = Account.create({ mask: plaid_client_account.mask, plaid_item_id: existing_plaid_item.id })

      expect { post :create }.to change { Account.count }.by(0)
      expect(account.reload.name).to eq(plaid_client_account.name)
    end

    it 'redirects to account_path' do
      post :create

      expect(response).to redirect_to(accounts_path)
    end
  end
end
