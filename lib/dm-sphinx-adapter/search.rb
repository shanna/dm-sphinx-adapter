module DataMapper
  module Sphinx
    class Search
      attr_reader :match, :filter, :sort

      def initialize match, filter, sort
        @match, @filter, @sort = match, filter, sort
      end

      def native?
        match.native? && filter.native? && sort.native?
      end
    end # Search
  end # Sphinx
end # DataMapper

