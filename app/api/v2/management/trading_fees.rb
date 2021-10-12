# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class TradingFees < Grape::API
        desc 'Returns trading_fees table as paginated collection' do
          @settings[:scope] = :read_trading_fees
        end
        params do
          optional :group,
                   type: String,
                   desc: 'Member group'
          optional :market_id,
                   type: String,
                   desc: 'Market id',
                   values: { value: -> { ::Market.pluck(:symbol).append(::TradingFee::ANY) },
                             message: 'Market does not exist' }
          optional :market_type,
                   values: { value: -> { ::Market::TYPES }, message: 'management.trading_fee.invalid_market_type' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:type] },
                   default: -> { ::Market::DEFAULT_TYPE }
          optional :page, type: Integer, default: 1, integer_gt_zero: true, desc: 'The page number (defaults to 1).'
          optional :limit, type: Integer, default: 100, range: 1..1000, desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
        end
        post '/fee_schedule/trading_fees' do
          TradingFee
            .order(id: :desc)
            .tap { |t| t.where!(market_id: params[:market_id]) if params[:market_id] }
            .tap { |t| t.where!(market_type: params[:market_type]) }
            .tap { |t| t.where!(group: params[:group]) if params[:group] }
            .tap { |q| present paginate(q), with: API::V2::Entities::TradingFee }
          status 200
        end
        # PUT: api/v2/management/fee_schedule/trading_fees/update
        desc 'Update trading fee' do
          @settings[:scope] = :write_markets
          success API::V2::Management::Entities::TradingFee
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.trading_fee.non_integer_id' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:id][:desc] }
          optional :maker,
                   type: { value: BigDecimal, message: 'admin.trading_fee.non_decimal_maker' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.trading_fee.invalid_maker' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:maker][:desc] }
          optional :taker,
                   type: { value: BigDecimal, message: 'admin.trading_fee.non_decimal_taker' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.trading_fee.invalid_taker' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:taker][:desc] }
          optional :group,
                   type: String,
                   coerce_with: ->(c) { c.strip.downcase },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:group][:desc] }
          optional :market_id,
                   type: String,
                   desc: -> { API::V2::Entities::TradingFee.documentation[:market_id][:desc] },
                   values: { value: -> { ::Market.spot.pluck(:symbol).append(::TradingFee::ANY) },
                             message: 'admin.trading_fee.market_doesnt_exist' }
          optional :market_type,
                   values: { value: -> { ::Market::TYPES }, message: 'admin.trading_fee.invalid_market_type' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:type] },
                   default: -> { ::Market::DEFAULT_TYPE }
        end
        put '/fee_schedule/trading_fees/update' do
          trading_fee = TradingFee.find(params[:id])
          if trading_fee.update(declared(params, include_missing: false).except(:id))
            present trading_fee, with: API::V2::Management::Entities::TradingFee
          else
            body errors: trading_fee.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
