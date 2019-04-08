# encoding: UTF-8
# frozen_string_literal: true

class BlockchainService
  attr_reader :blockchain, :adapter

  def initialize(blockchain)
    @blockchain = blockchain
    @adapter = Peatio::BlockchainService
                 .adapter_for(blockchain.client.to_sym)
                 .new(blockchain: blockchain, cache: Rails.cache)
  end

  def process_blockchain(block_limit: 250, force: false)
    latest_block_number = @adapter.latest_block_number

    if !force && blockchain.height + blockchain.min_confirmations >= latest_block_number
      Rails.logger.info do
        "Skip synchronization. No new blocks detected height: "
        "#{blockchain.height}, latest_block: #{latest_block_number}"
      end
      return
    end

    from_block = blockchain.height
    to_block = [latest_block_number, from_block + block_limit].min
    from_block.upto(to_block, &method(:process_block))

    update_height!

    # TODO: Deal with errors better!!!
  # rescue => e
  #   report_exception(e)
  #   Rails.logger.info { "Exception was raised during block processing." }
  end

  protected

  def process_block(block_number)
    @adapter.fetch_block!(block_number)

    addresses = PaymentAddress.where(currency: blockchain.currencies).readonly
    withdrawals = Withdraws::Coin.confirming.where(currency: blockchain.currencies).readonly

    ActiveRecord::Base.transaction do
      @adapter.filtered_deposits(addresses, &method(:update_or_create_deposit!))
      @adapter.filtered_withdrawals(withdrawals, &method(:update_withdrawal!))
    end
  end

  def update_or_create_deposit!(deposit_hash)
    if deposit_hash[:amount] <= deposit_hash[:currency].min_deposit_amount
      # Currently we just skip tiny deposits.
      Rails.logger.info do
        "Skipped deposit with txid: #{deposit_hash[:txid]} with amount: #{deposit_hash[:amount]}"\
        " from #{deposit_hash[:address]} in block number #{deposit_hash[:block_number]}"
      end
      return
    end

    # If deposit doesn't exist create it and assign attributes.
    deposit =
      Deposits::Coin
        .where(currency: blockchain.currencies)
        .find_or_create_by!(deposit_hash.slice(:txid, :txout)) do |deposit|
          deposit.assign_attributes(deposit_hash)
        end

    deposit.update_column(:block_number, deposit_hash.fetch(:block_number))
    if deposit.confirmations >= blockchain.min_confirmations && deposit.accept!
      deposit.collect!
    end
  end

  def update_withdrawal!(withdrawal_hash, successful = true)
    withdrawal =
      Withdraws::Coin
        .confirming
        .where(currency: blockchain.currencies)
        .find_by(withdrawal_hash.slice(:txid)) do |withdrawal|
          withdrawal.assign_attributes(withdrawal_hash)
        end

    # Skip non-existing in database withdrawals.
    if withdrawal.blank?
      Rails.logger.info { "Skipped withdrawal: #{withdrawal_hash[:txid]}." }
      return
    end

    unless successful
      Rails.logger.info { "Failed withdrawal detected: #{withdrawal_hash[:txid]}."}
      withdrawal.fail!
      return
    end

    withdrawal.update_column(:block_number, withdrawal_hash.fetch(:block_number))
    withdrawal.success! if withdrawal.confirmations >= blockchain.min_confirmations
  end

  def update_height!
    raise Error, "#{blockchain.name} height was reset." if blockchain.height != blockchain.reload.height
    if @adapter.latest_block_number - @adapter.current_block_number >= blockchain.min_confirmations
      blockchain.update(height: @adapter.current_block_number)
    end
  end
end
