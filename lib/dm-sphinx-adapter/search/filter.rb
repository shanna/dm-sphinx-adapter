require 'lib/dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      class Filter < Statement
        include DataMapper::Query::Conditions
        include Extlib::Assertions

        def statement
          condition_statement(@query.conditions) || []
        end

        protected
          def operation_statement(operation)
            expression = operation.map{|op| condition_statement(op)}.compact
            return if expression.empty?

            case operation
              when AndOperation then expression
              when NotOperation
                expression[2] = false # Ick?
                expression
              else # TODO: fail_native
            end
          end

          def comparison_statement(comparison)
            field     = comparison.subject.field
            value     = comparison.value.dup
            statement = case comparison
              when EqualToComparison then [field, value, true]
              # gt, lt and whatever else filters support.
              else fail_native("Comparison #{comparison.slug}'.") && return
            end

            statement
          end
      end
    end # Search
  end # Sphinx
end # DataMapper
