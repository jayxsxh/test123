# encoding: UTF-8
# frozen_string_literal: true

describe Currency do
  context 'fiat' do
    let(:currency) { Currency.find(:usd) }
    it 'allows to change deposit fee' do
      currency.update!(deposit_fee: 0.25)
      expect(currency.deposit_fee).to eq 0.25
    end
  end

  context 'coin' do
    let(:currency) { Currency.find(:btc) }
    it 'doesn\'t allow to change deposit fee' do
      currency.update!(deposit_fee: 0.25)
      expect(currency.deposit_fee).to eq 0
    end

    it 'validates blockchain_key' do
      currency.blockchain_key = 'an-nonexistent-key'
      expect(currency.valid?).to be_falsey
      expect(currency.errors[:blockchain_key].size).to eq(1)

      currency.blockchain_key = 'btc-testnet' # an existent key
      expect(currency.valid?).to be_truthy
      expect(currency.errors[:blockchain_key]).to be_empty
    end
  end

  it 'disables markets when currency is set to disabled' do
    currency = Currency.find(:eth)
    expect(Market.find(:btcusd).state.enabled?).to be_truthy
    expect(Market.find(:btceth).state.enabled?).to be_truthy

    currency.update!(enabled: false)
    expect(Market.find(:btcusd).state.enabled?).to be_truthy
    expect(Market.find(:btceth).state.enabled?).to be_falsey

    currency.update!(enabled: true)
    expect(Market.find(:btcusd).state.enabled?).to be_truthy
    expect(Market.find(:btceth).state.enabled?).to be_falsey
  end

  it 'allows to disable all dependent markets' do
    Market.where.not(base_unit: 'btc').update_all(state: :disabled)
    currency = Currency.find(:btc)
    currency.update(enabled: false) # FIXME: this line has no effect here.
    expect(currency.valid?).to be_truthy
    expect(currency.errors[:currency].size).to eq(0)
  end

  it 'doesn\'t allow to disable display currency' do
    currency = Currency.find(:usd)
    currency.update(enabled: false)
    expect(currency.errors.full_messages).to eq ['Cannot disable display currency!']
  end
end
