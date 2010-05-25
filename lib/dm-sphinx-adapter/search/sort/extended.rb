require 'dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      module Sort
        class Extended < Statement
          include DataMapper::Query::Conditions

          def mode
            :extended # Only supported mode for now.
          end

          #--
          # TODO: Support @id, @weight, @rank, @relevance, @random somehow.
          def statement
            fail_native 'More than 5 sort conditions.' if @query.order.size > 5
            @query.order.map{|by| '%s %s' % [by.target.field, by.operator == :asc ? 'ASC' : 'DESC']}.join(', ')
          end
        end # Extended
      end # Sort
    end # Search
  end # Sphinx
end # DataMapper
