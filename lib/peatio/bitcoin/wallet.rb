module Bitcoin
  class Wallet < Peatio::Wallet::Abstract

    def initialize(settings = {})
      @settings = settings
    end

    def configure(settings = {})
      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = settings.fetch(:wallet) do
        raise Peatio::Blockchain::MissingSettingError, :wallet
      end.slice(:uri, :address)

      @currency = settings.fetch(:currency) do
        raise Peatio::Blockchain::MissingSettingError, :wallet
      end.slice(:id, :base_factor, :options)
    end

    def create_address!(_options = {})
      address = client.json_rpc(:getnewaddress)
      Peatio::BlockchainAddress.new(address: address)
    rescue Bitcoin::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def create_transaction!(transaction)
      txid = client.json_rpc(:sendtoaddress,
                             [
                               transaction.to_address,
                               transaction.amount,
                               '',
                               '',
                               true # subtract fee from transaction amount.
                             ])
      transaction.hash = txid
      transaction
    rescue Bitcoin::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    private

    def client
      uri = @wallet.fetch(:uri) { raise Peatio::Blockchain::MissingSettingError, :uri }
      @client ||= Client.new(uri)
    end
  end
end