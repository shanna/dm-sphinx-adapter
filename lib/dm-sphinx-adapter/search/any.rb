require 'dm-sphinx-adapter/search/match'

module DataMapper
  module Sphinx
    class Search

      # ==== Notes
      # * While DM's Query interface doesn't support OR the AND connective operator can also be used to join comperison
      # operators in this match mode.
      class Any < Match
        def mode
          :any
        end

        protected
          def operation_statement operation
            expression = operation.map{|op| condition_statement(op)}.compact
            return if expression.empty?

            case operation
              when AndOperation then expression.join(' ')
              when OrOperation  then expression.join(' ')
              else fail_native("Operation #{operation.slug}.") && return
            end
          end

          def comparison_statement comparison
            case comparison
              when EqualToComparison then quote(comparison.value)
              else fail_native("Comparison #{comparison.slug}.") && return
            end
          end
      end # Any
    end # Search
  end # Sphinx
end # DataMapper
