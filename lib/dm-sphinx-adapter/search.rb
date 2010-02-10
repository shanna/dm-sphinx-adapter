module DataMapper
  module Sphinx
    class Search
      include Extlib::Assertions
      attr_reader :search, :filters

      def initialize(search, filters)
        assert_kind_of 'search', search, Search::Statement # TODO: Add Search::Mode to subclass.
        assert_kind_of 'filters', filters, Search::Filters
        @search, @filters = search, filters
      end

      def native?
        search.native? && filters.native?
      end
    end # Search
  end # Sphinx
end # DataMapper

