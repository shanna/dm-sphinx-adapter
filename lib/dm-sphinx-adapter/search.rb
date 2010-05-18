module DataMapper
  module Sphinx
    class Search
      attr_reader :match, :filter

      def initialize match, filter
        @match, @filter = match, filter
      end

      def native?
        match.native? && filter.native?
      end
    end # Search
  end # Sphinx
end # DataMapper

