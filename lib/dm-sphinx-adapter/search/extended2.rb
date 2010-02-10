require 'lib/dm-sphinx-adapter/search/mode'

module DataMapper
  module Sphinx
    class Search
      class Extended2 < Mode
        include DataMapper::Sphinx::Query::Conditions

        def slug
          :extended2
        end

        protected
          def operation_statement(operation)
            expression = operation.map{|op| condition_statement(op)}.compact
            return if expression.empty?

            case operation
              when NotOperation then ['!(', expression.join, ')'].join
              when AndOperation then ['(', expression.join(' & '), ')'].join
              when OrOperation  then ['(', expression.join(' | '), ')'].join
            end
          end

          #--
          # TOOD: I really need a rule here about when a phrase is used or not.
          def comparison_statement(comparison)
            field = comparison.subject.field
            value = comparison.value.dup
            case comparison
              when EqualToComparison   then '@%s %s'       % [field, quote(value)]
              when InclusionComparison then '@%s (%s)'     % [field, value.map{|v| quote(v)}.join('|')]
              when PositionComparison  then '@%s[%d] "%s"' % [field, value[1], quote(value[0])]
              when PhraseComparison    then '@%s "%s"'     % [field, quote(value)]
              when ProximityComparison then '@%s "%s"~%d'  % [field, quote(value[0]), value[1]]
              when QuorumComparison    then '@%s "%s"/%d'  % [field, quote(value[0]), value[1]]
              when ExactComparison     then '@%s ="%s"'    % [field, quote(value)]
              else fail_native("Comparison #{comparison.slug}'.") && return
            end
          end

          def quote(value)
            value.to_s.gsub(/[\(\)\|\-!@~"&\/]/){|char| "\\#{char}"}
          end
      end # Extended2
    end # Search
  end # Sphinx
end # DataMapper