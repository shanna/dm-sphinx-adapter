require 'dm-sphinx-adapter/search/match'

module DataMapper
  module Sphinx
    class Search
      # ==== Notes
      # * The .equal (default), .exact and .phrase operators are all treated the same in this match mode.
      # * The AND operator is supported but the order of the conditions isn't guaranteed when using DM's Hash based
      # query interface.
      class Phrase < Match
        def mode
          :phrase
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
              when EqualToComparison, ExactComparison, PhraseComparison then quote(comparison.value)
              else fail_native("Comparison #{comparison.slug}.") && return
            end
          end
      end # Phrase
    end # Search
  end # Sphinx
end # DataMapper
