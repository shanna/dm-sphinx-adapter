module DataMapper
  module Sphinx
    class Search
      include Extlib::Assertions
      attr_reader :match, :filter

      def initialize(match, filter)
        assert_kind_of 'match', match, Search::Match
        assert_kind_of 'filter', filter, Search::Filter
        @match, @filter = match, filter
      end

      def native?
        match.native? && filter.native?
      end
    end # Search
  end # Sphinx
end # DataMapper

