module API
  module V2
    module Management
      module Entities
        class TradingFee < ::API::V2::Entities::TradingFee
          expose(
            :id,
            documentation:{
              type: Integer,
              desc: 'Unique trading fee table identifier in database.'
            }
          )

          expose(
            :group,
            documentation:{
              type: String,
              desc: 'Member group for define maker/taker fee.'
            }
          )

          expose(
            :market_id,
            documentation:{
              type: String,
              desc: 'Market id for define maker/taker fee.'
            }
          )

          expose(
            :market_type,
            documentation:{
              type: String,
              desc: 'Market type.'
            }
          )

          expose(
            :maker,
            documentation:{
              type: BigDecimal,
              desc: 'Market maker fee.'
            }
          )

          expose(
            :taker,
            documentation:{
              type: BigDecimal,
              desc: 'Market taker fee.'
            }
          )
        end
      end
    end
  end
end
