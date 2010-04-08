module DataMapper
  module Sphinx
    class Search
      #--
      # TODO: Not sold on the name at all.
      class Statement
        include DataMapper::Query::Conditions
        include Extlib::Assertions

        def initialize(query)
          assert_kind_of 'query', query, DataMapper::Query
          @query, @native = query, []
        end

        def native?
          @native.empty?
        end

        def statement
          condition_statement(@query.conditions) || ''
        end

        protected
          def condition_statement(conditions)
            case conditions
              when AbstractOperation  then operation_statement(conditions)
              when AbstractComparison then comparison_statement(conditions)
              when Array              then conditions.first # TODO: Raw bind values.
            end
          end

          # Abstract.
          def operation_statement(operation)
            raise NotImplementedError
          end

          # Abstract.
          def comparison_statement(comparison)
            raise NotImplementedError
          end

          def fail_native(why)
            @native << why
          end
      end # Statement
    end # Search
  end # Sphinx
end # DataMapper

