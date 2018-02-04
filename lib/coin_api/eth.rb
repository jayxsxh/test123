# frozen_string_literal: true

module CoinAPI
  class ETH < ::CoinAPI::JsonRPC::V2
    def load_balance!
      do_request(:eth_getBalance, hot_wallet_address, 'latest').to_d
    end
  end
end
