require 'dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      class Filter < Statement
        include DataMapper::Query::Conditions

        def statement
          condition_statement(@query.conditions) || []
        end

        protected
          def operation_statement operation
            expression = operation.map{|op| condition_statement(op)}.compact
            return if expression.empty?

            case operation
              when AndOperation then expression.flatten
              when NotOperation then expression.map{|e| e.exclude = true; e}.flatten
              else # TODO: fail_native
            end
          end

          def comparison_statement comparison
            field = comparison.subject.field
            value = comparison.value
            unless comparison.is_a?(EqualToComparison) || comparison.is_a?(InclusionComparison)
              fail_native("Comparison #{comparison.slug}.")
              return
            end

            Riddle::Client::Filter.new(comparison.subject.field, typecast(value), false)
          end

          def typecast value
            value.is_a?(Range) ? value : [value].flatten
          end
      end
    end # Search
  end # Sphinx
end # DataMapper
