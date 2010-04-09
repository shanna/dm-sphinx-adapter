require 'riddle'

module DataMapper
  module Sphinx
    class Connection < Riddle::Client
      def initialize(host = 'localhost', port = '9312')
        super
        reset
      end

      def dispose
        reset && true
      end

      def reset
        super
        @match_mode = :extended2
      end

      def query(statement, index, comment = '')
        result = super

        # TODO: Filters.
        DataMapper.logger.debug(
          "(%1.6f) sphinx search:%s, mode: %s, index: %s" %
          [result[:time], statement.inspect, @match_mode, index]
        )
        DataMapper.logger.warn(result[:warning]) unless result[:warning].blank?
        DataMapper.logger.error(result[:error]) unless result[:error].blank?

        result.fetch(:matches, [])
      end
    end # Connection
  end # Sphinx
end # DataMapper
