module DataMapper
  module Sphinx
    # Extends DM::Query with the ability to cast itself as a DM::Sphinx::Search object.
    class Query < DataMapper::Query
      # The cast Search object.
      attr_reader :search

      #--
      # TODO: Document extra :mode and :filters options.
      # TODO: This still smells 'iffy.
      def initialize(repository, model, options = {})
        # The Query wouldn't pass validation if I didn't remove the extra arguments.
        mode    = options.delete(:mode)
        filters = options.delete(:filters)
        super

        filters = Search::Filters.new(self.dup.clear.update(filters || {}))
        search  = case mode
          when :extended2, nil then Search::Extended2.new(self)
          # TODO: Modes.
          # when :extended
          # when :all
          # when :any
          # when :phrase
          # when :boolean
          else raise ArgumentError, "+options[:mode]+ used an unknown mode #{mode.inspect}."
        end
        @search = Search.new(search, filters)
      end
    end # Query
  end # Sphinx
end # DataMapper

