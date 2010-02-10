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

      def query(*args)
        result = super

        # TODO: connection.logger.info(
        #   %q{'(%.3f): '%s' in '%s' found %d documents} % [result[:time], search, @index, result[:total]]
        # )
        # TODO: Connection.logger.warn(result[:warning]) unless result[:warning].blank?
        # TODO: Connection.logger.error(result[:error]) unless result[:error].blank?
        # TODO: Raise result[:error] also.
        $stderr.puts 'WARNING: ' + result[:warning] unless result[:warnings].blank?
        $stderr.puts 'ERROR: ' + result[:error] unless result[:error].blank?

        result.fetch(:matches, [])
      end
    end # Connection
  end # Sphinx
end # DataMapper
