# encoding: UTF-8
# frozen_string_literal: true

module BelongsToCurrency
  extend ActiveSupport::Concern

  included do
    belongs_to :currency, required: true

    validate do
      account  = try(:account)
      currency = self.currency
      if account && currency && account.currency != currency
        errors.add(:currency, :invalid)
        errors.add(:account, :invalid)
      end
    end

    delegate :coin?, :fiat?, to: :currency

    scope :with_currency, -> (model_or_id) do
      id = case model_or_id
        when Currency then model_or_id.code
        else model_or_id
      end
      where(currency_id: id)
    end

    def confirmations
      return 0 if block_number.blank?
      latest_block_number - block_number
    end

    def latest_block_number
      currency.blockchain_api.latest_block_number
    rescue NoMethodError
      currency.api.latest_block_number # For Coin API
    end

  end
end
