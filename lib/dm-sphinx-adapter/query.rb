module DataMapper
  module Adapters
    module Sphinx

      ##
      # Sphinx extended search query string from DataMapper query.
      class Query
        include Extlib::Assertions

        ##
        # Sphinx extended search query string from DataMapper query.
        #
        # If the query has no conditions an '' empty string will be generated possibly triggering Sphinx's full scan
        # mode.
        #
        # @see    http://www.sphinxsearch.com/doc.html#extended-syntax
        # @see    http://www.sphinxsearch.com/doc.html#searching
        # @see    http://www.sphinxsearch.com/doc.html#conf-docinfo
        # @param  [DataMapper::Query]
        def initialize(query)
          assert_kind_of 'query', query, DataMapper::Query
          @query  = []

          if query.conditions.empty?
            @query << ''
          else
            query.conditions.each do |operator, property, value|
              next if property.kind_of? Sphinx::Attribute # Filters are added elsewhere.
              normalized = normalize_value(value)
              @query << case operator
                when :eql, :like then '@%s "%s"'  % [property.field.to_s, normalized.join(' ')]
                when :not        then '@%s -"%s"' % [property.field.to_s, normalized.join(' ')]
                when :in         then '@%s (%s)'  % [property.field.to_s, normalized.map{|v| %{"#{v}"}}.join(' | ')]
                when :raw        then "#{property}"
                else raise NotImplementedError.new("Sphinx: Query fields do not support the #{operator} operator")
              end
            end
          end
        end

        ##
        # The extended sphinx query string.
        # @return [String]
        def to_s
          @query.join(' ')
        end

        protected
          ##
          # Normalize and escape DataMapper query value(s) to escaped sphinx query values.
          # @param [String, Array] value The query value.
          # @return [Array]
          def normalize_value(value)
            [value].flatten.map do |v|
              v.to_s.gsub(/[\(\)\|\-!@~"&\/]/){|char| "\\#{char}"}
            end
          end
      end # Query
    end # Sphinx
  end # Adapters
end # DataMapper
