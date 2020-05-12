# encoding: UTF-8
# frozen_string_literal: true

describe Workers::AMQP::DepositCoinAddress do
  let(:member) { create(:member, :barong) }
  let(:address) { Faker::Blockchain::Bitcoin.address }
  let(:secret) { PasswordGenerator.generate(64) }
  let(:wallet) { Wallet.active_retired.deposit.find_by(blockchain_key: 'btc-testnet') }
  let(:payment_address) { member.payment_address(wallet.id) }
  let(:create_address_result) do
    { address: address,
      secret: secret,
      details: { label: 'new-label' } }
  end

  subject { member.payment_address(wallet.id).address }

  it 'raise error on databse connection error' do
    expect(Account).to receive(:find_by_id).and_raise(Mysql2::Error::ConnectionError.new(''))
    expect {
      Workers::AMQP::DepositCoinAddress.new.process(member_id: member.id, wallet_id: wallet.id)
    }.to raise_error Mysql2::Error::ConnectionError
  end

  context 'wallet service' do
    before do
      expect_any_instance_of(WalletService)
                    .to receive(:create_address!)
                    .and_return(create_address_result)
    end

    it 'is passed to wallet service' do
      Workers::AMQP::DepositCoinAddress.new.process(member_id: member.id, wallet_id: wallet.id)
      expect(subject).to eq address
      payment_address.reload
      expect(payment_address.as_json
               .deep_symbolize_keys
               .slice(:address, :secret, :details)).to eq(create_address_result)
    end

    context 'empty address details' do
      let(:create_address_result) do
        { address: address,
          secret: secret }
      end

      it 'is passed to wallet service' do
        Workers::AMQP::DepositCoinAddress.new.process(member_id: member.id, wallet_id: wallet.id)
        expect(subject).to eq address
        payment_address.reload
        expect(payment_address.as_json
                 .deep_symbolize_keys
                 .slice(:address, :secret, :details)).to eq(create_address_result.merge(details: {}))
      end
    end

    context 'should skip address with details' do
      let(:create_address_result) do
        { address: nil,
          secret: secret,
          details: {
            address_id: 'address_id'
          } }
      end

      it 'shouldnt create address' do
        Workers::AMQP::DepositCoinAddress.new.process(member_id: member.id, wallet_id: wallet.id)
        expect(subject).to eq nil
        payment_address.reload
        expect(payment_address.as_json
                 .deep_symbolize_keys
                 .slice(:address, :secret, :details)).to eq(create_address_result.merge(details: {:address_id=>"address_id"}))
      end
    end
  end
end
