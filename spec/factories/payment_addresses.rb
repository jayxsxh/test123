# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :payment_address do
    address { Faker::Bitcoin.address }
    currency { Currency.find(:usd) }
    account { create(:member, :level_3).get_account(:usd) }

    trait :btc_address do
      currency { Currency.find(:btc) }
      account { create(:member, :level_3).get_account(:btc) }
    end

    trait :eth_address do
      currency { Currency.find(:eth) }
      account { create(:member, :level_3).get_account(:eth) }
    end

    factory :btc_payment_address, traits: [:btc_address]
    factory :eth_payment_address, traits: [:eth_address]
  end
end
