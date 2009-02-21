module DataMapper
  module Adapters
    module Sphinx

      # Sphinx extended search query string from DataMapper query.
      class Query
        include Extlib::Assertions

        # Initialize a new extended Sphinx query from a DataMapper::Query object.
        #
        # If the query has no conditions an '' empty string will be generated possibly triggering Sphinx's full scan
        # mode.
        #
        # ==== See
        # * http://www.sphinxsearch.com/doc.html#searching
        # * http://www.sphinxsearch.com/doc.html#conf-docinfo
        # * http://www.sphinxsearch.com/doc.html#extended-syntax
        #
        # ==== Raises
        # NotImplementedError:: DataMapper operators that can't be expressed in the extended sphinx query syntax.
        #
        # ==== Parameters
        # query<DataMapper::Query>:: DataMapper query object.
        def initialize(query)
          assert_kind_of 'query', query, DataMapper::Query
          @query  = []

          if query.conditions.empty?
            @query << ''
          else
            query.conditions.each do |operator, property, value|
              next if property.kind_of? Sphinx::Attribute # Filters are added elsewhere.
              normalized = normalize_value(value)
              field      = property.field(query.repository.name) unless operator == :raw
              @query << case operator
                when :eql, :like then '@%s "%s"'  % [field.to_s, normalized.join(' ')]
                when :not        then '@%s -"%s"' % [field.to_s, normalized.join(' ')]
                when :in         then '@%s (%s)'  % [field.to_s, normalized.map{|v| %{"#{v}"}}.join(' | ')]
                when :raw        then "#{property}"
                else raise NotImplementedError.new("Sphinx: Query fields do not support the #{operator} operator")
              end
            end
          end
        end

        # ==== Returns
        # String:: The extended sphinx query string.
        def to_s
          @query.join(' ')
        end

        protected
          # Normalize and escape DataMapper query value(s) to escaped sphinx query values.
          #
          # ==== Parameters
          # value<String, Array>:: The query value.
          #
          # ==== Returns
          # Array:: An array of one or more query values.
          def normalize_value(value)
            [value].flatten.map do |v|
              v.to_s.gsub(/[\(\)\|\-!@~"&\/]/){|char| "\\#{char}"}
            end
          end
      end # Query
    end # Sphinx
  end # Adapters
end # DataMapper
