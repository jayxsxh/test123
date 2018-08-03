# encoding: UTF-8
# frozen_string_literal: true


class Wallet < ActiveRecord::Base
  serialize :gateway, JSON

  include BelongsToCurrency
  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  validates :name, :address, presence: true
  validates :status, inclusion: { in: %w[active disabled] }
  validates :kind, inclusion: { in: %w[hot warm cold deposit] }
  validates :nsig, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :max_balance, numericality: { greater_than_or_equal_to: 0}
  # FIXME: add json validation.
  validates :gateway, length: { maximum: 1000 }

  scope :active, -> { where(status: :active) }
  scope :deposit, -> { where(kind: :deposit) }
  scope :withdraw, -> { where.not(kind: :deposit) }

  def wallet_url
    blockchain.explorer_address.gsub('#{address}', address)
  end

  def secret
    gateway.dig('options','secret')
  end
end

# == Schema Information
# Schema version: 20180727054453
#
# Table name: wallets
#
#  id             :integer          not null, primary key
#  blockchain_key :string(32)
#  currency_id    :string(5)
#  name           :string(64)
#  address        :string(255)      not null
#  kind           :string(32)       not null
#  nsig           :integer
#  gateway        :string(1000)     default({}), not null
#  max_balance    :decimal(32, 16)  default(0.0), not null
#  parent         :integer
#  status         :string(32)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
