require 'dm-sphinx-adapter/search/match'

module DataMapper
  module Sphinx
    class Search
      class Match
        class Boolean < Match
          def mode
            :boolean
          end

          protected
            def operation_statement operation
              expression = operation.map{|op| condition_statement(op)}.compact
              return if expression.empty?

              case operation
                when NotOperation then ['!(', expression.join, ')'].join
                when AndOperation then ['(', expression.join(' & '), ')'].join
                when OrOperation  then ['(', expression.join(' | '), ')'].join
              end
            end

            def comparison_statement comparison
              case comparison
                when EqualToComparison, ExactComparison then quote(comparison.value)
                when InclusionComparison                then comparison.value.map{|v| quote(v)}.join('|')
                else fail_native("Comparison #{comparison.slug}.") && return
              end
            end
        end # Boolean
      end # Match
    end # Search
  end # Sphinx
end # DataMapper
