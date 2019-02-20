# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Helpers
      extend Memoist

      def authenticate!
        current_user or raise Peatio::Auth::Error
      end

      def deposits_must_be_permitted!
        if current_user.level < ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_DEPOSIT').to_i
          error!({ errors: ['account.deposit.not_permitted'] }, 403)
        end
      end

      def withdraws_must_be_permitted!
        if current_user.level < ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_WITHDRAW').to_i
          error!({ errors: ['account.withdraw.not_permitted'] }, 403)
        end
      end

      def trading_must_be_permitted!
        if current_user.level < ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_TRADING').to_i
          error!({ errors: ['market.trade.not_permitted'] }, 403)
        end
      end

      def withdraw_api_must_be_enabled!
        if ENV.false?('ENABLE_ACCOUNT_WITHDRAWAL_API')
          error!({ errors: ['withdraw.status.disabled'] }, 422)
        end
      end

      def current_user
        # JWT authentication provides member email.
        if env.key?('api_v2.authentic_member_email')
          Member.find_by_email(env['api_v2.authentic_member_email'])
        end
      end
      memoize :current_user

      def current_market
        ::Market.enabled.find_by_id(params[:market])
      end
      memoize :current_market

      def time_to
        params[:timestamp].present? ? Time.at(params[:timestamp]) : nil
      end

      def build_order(attrs)
        (attrs[:side] == 'sell' ? OrderAsk : OrderBid).new \
          state:         ::Order::WAIT,
          member:        current_user,
          ask:           current_market&.base_unit,
          bid:           current_market&.quote_unit,
          market:        current_market,
          ord_type:      attrs[:ord_type] || 'limit',
          price:         attrs[:price],
          volume:        attrs[:volume],
          origin_volume: attrs[:volume]
      end

      def create_order(attrs)
        create_order_errors = {
          ::Account::AccountError => 'market.account.insufficient_balance',
          ::Order::InsufficientMarketLiquidity => 'market.order.insufficient_market_liquidity',
          ActiveRecord::RecordInvalid => 'market.order.invalid_volume_or_price'
        }

        order = build_order(attrs)
        Ordering.new(order).submit
        order
      rescue => e
        message = create_order_errors.fetch(e.class, 'market.order.create_error')
        report_exception_to_screen(e)
        error!({ errors: [message] }, 422)
      end

      def order_param
        params[:order_by].downcase == 'asc' ? 'id asc' : 'id desc'
      end

      def format_ticker(ticker)
        permitted_keys = %i[buy sell low high open last volume
                            avg_price price_change_percent]

        # Add vol for compatibility with old API.
        formatted_ticker = ticker.slice(*permitted_keys)
                             .merge(vol: ticker[:volume])
        { at: ticker[:at],
          ticker: formatted_ticker }
      end
    end
  end
end
