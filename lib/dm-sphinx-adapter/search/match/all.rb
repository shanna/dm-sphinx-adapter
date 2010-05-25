require 'dm-sphinx-adapter/search/match'

module DataMapper
  module Sphinx
    class Search
      class Match
        class All < Match
          def mode
            :all
          end

          protected
            def operation_statement operation
              expression = operation.map{|op| condition_statement(op)}.compact
              return if expression.empty?

              case operation
                when AndOperation then expression.join(' ')
                else fail_native("Operation #{operation.slug}.") && return
              end
            end

            def comparison_statement comparison
              case comparison
                when EqualToComparison then quote(comparison.value)
                else fail_native("Comparison #{comparison.slug}.") && return
              end
            end
        end # All
      end # Match
    end # Search
  end # Sphinx
end # DataMapper
