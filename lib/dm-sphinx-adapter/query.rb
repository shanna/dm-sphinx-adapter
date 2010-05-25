module DataMapper
  module Sphinx
    class Query < DataMapper::Query
      # The cast Search object.
      attr_reader :search

      #--
      # TODO: Document extra :mode and :filters options.
      # TODO: This still smells 'iffy.
      # TODO: Perhaps construct the sort *before* calling super so we can accept '@*' targets?
      def initialize repository, model, options = {}
        # Set the sort order to [] if no explicit order is defined so we don't end up with the table default.
        options.update(:order => []) unless options.key?(:order)

        # The Query wouldn't pass validation if I didn't remove the extra arguments.
        mode   = options.delete(:mode)
        filter = options.delete(:filter)
        super

        filter = Search::Filter.new(self.dup.clear.update(filter || {}))
        match  = case mode
          when :extended2, nil then Search::Match::Extended2.new(self)
          when :all            then Search::Match::All.new(self)
          when :any            then Search::Match::Any.new(self)
          when :phrase         then Search::Match::Phrase.new(self)
          when :boolean        then Search::Match::Boolean.new(self)
          else raise ArgumentError, "+options[:mode]+ used an unknown mode #{mode.inspect}."
        end
        sort    = order.size == 0 ? Search::Sort::Rank.new(self) : Search::Sort::Extended.new(self)
        @search = Search.new(match, filter, sort)
      end
    end # Query
  end # Sphinx
end # DataMapper

