# encoding: UTF-8
# frozen_string_literal: true

describe Admin::BlockchainsController, type: :controller do
  let(:member) { create(:admin_member) }
  let :attributes do
    { key:                              'eth-rinkeby-new',
      name:                             'Ethereum Rinkeby',
      client:                           'ethereum',
      server:                           'http://127.0.0.1:8545',
      height:                           250_000_0,
      min_confirmations:                3,
      explorer_address:                 'https://etherscan.io/address/\#{address}',
      explorer_transaction:             'https://etherscan.io/tx/\#{txid}',
      status:                           'active'
    }
  end

  let(:existing_blockchain) { Blockchain.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates blockchain with valid attributes' do
      expect do
        post :create, blockchain: attributes
        expect(response).to redirect_to admin_blockchains_path
      end.to change(Blockchain, :count).by(1)
      blockchain = Blockchain.last
      attributes.each { |k, v| expect(blockchain.method(k).call).to eq v }
    end
  end

  describe '#update' do
    let :new_attributes do
      { key:                              'btc-test',
        name:                             'Bitcoin Testnet',
        client:                           'bitcoin',
        server:                           'http://127.0.0.1:18332',
        height:                           300_000_0,
        min_confirmations:                3,
        explorer_address:                 'https://www.blocktrail.com/BCC/address/\#{address}',
        explorer_transaction:             'https://blockchain.info/tx/\#{txid}',
        status:                           'active'
      }
    end

    let :final_attributes do
      new_attributes.merge \
        attributes.slice \
          :client,
          :key
    end

    before { request.env['HTTP_REFERER'] = '/admin/blockchains' }

    it 'updates blockchain attributes' do
      post :create, blockchain: attributes
      blockchain = Blockchain.last
      attributes.each { |k, v| expect(blockchain.method(k).call).to eq v }
      post :update, blockchain: new_attributes, id: blockchain.id
      expect(response).to redirect_to admin_blockchains_path
      blockchain.reload
      final_attributes.each { |k, v| expect(blockchain.method(k).call).to eq v }
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of blockchain' do
      expect { delete :destroy, id: existing_blockchain.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end

end
