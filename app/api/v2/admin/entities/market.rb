# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Market < API::V2::Entities::Market
          expose(
            :engine_id,
            documentation: {
              type: Integer,
              desc: 'Market position.'
            }
          ) do |market, _option|
            market.engine
          end


          expose(
            :position,
            documentation: {
              type: Integer,
              desc: 'Market position.'
            }
          )

          expose(
            :data,
            documentation: {
              type: JSON,
              desc: 'Market additional data.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Market created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Market updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
