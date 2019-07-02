# frozen_string_literal: true

module Bench
  module Injectors
    class Dummy < Base
      extend Memoist

      def initialize(config)
        super
        config.reverse_merge!(default_config)
        %i[min_volume max_volume min_price max_price].each do |var|
          instance_variable_set(:"@#{var}", config[var])
        end
      end

      private

      def construct_order
        market = @markets.sample
        type = config.fetch(:side) { %w[OrderBid OrderAsk].sample }
        if @order_number % 4 == 0 && @order_number > 20
          { type:     type,
            state:    Order::WAIT,
            member:   @members.sample,
            market:   market,
            ask:      market.base_unit,
            bid:      market.quote_unit,
            ord_type: :market,
            volume:   rand(@min_volume..@max_volume) }
        else
          { type:     type,
            state:    Order::WAIT,
            member:   @members.sample,
            market:   market,
            ask:      market.base_unit,
            bid:      market.quote_unit,
            ord_type: :limit,
            price:    config.fetch(:price) { rand(@min_price..@max_price) },
            volume:   rand(@min_volume..@max_volume) }
        end

      end

      def default_config
        { min_volume: 0.1,
          max_volume: 1,
          min_price:  0.5,
          max_price:  2 }
      end
      memoize :default_config
    end
  end
end
