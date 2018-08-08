# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class WalletsController < BaseController
    def index
      @wallets = Wallet.all.page(params[:page]).per(100)
    end

    def show
      @wallet = Wallet.find(params[:id])
    end

    def new
      @wallet = Wallet.new(default_params)
      render :show
    end

    def create
      @wallet = Wallet.new(wallet_params)
      if @wallet.save
        redirect_to admin_wallets_path
      else
        flash[:alert] = @wallet.errors.full_messages
        render :show
      end
    end

    def update
      @wallet = Wallet.find(params[:id])
      if @wallet.update(wallet_params)
        redirect_to admin_wallets_path
      else
        flash[:alert] = @wallet.errors.full_messages
        redirect_to :back
      end
    end

    def show_client_info
      @client = params[:client]
      @wallet = Wallet.find_by_id(params[:id]) || Wallet.new
    end

    private

    def wallet_params
      params.require(:wallet).permit(permitted_wallet_attributes)
    end

    def default_params
      { gateway: { options: {} } }
    end

    def permitted_wallet_attributes
      %i[
        currency_id
        blockchain_key
        name
        address
        max_balance
        kind
        nsig
        parent
        status
        client
        uri
        secret
        bitgo_test_net
        bitgo_wallet_address
        bitgo_wallet_passphrase
        bitgo_rest_api_root
        bitgo_rest_api_access_token
      ]
    end

  end
end
