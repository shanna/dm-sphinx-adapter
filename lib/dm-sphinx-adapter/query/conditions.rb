module DataMapper
  module Sphinx
    class Query
      #--
      # Yeah I'm just hacking this stuff in. Fingers crossed you'll be able to legitimately add operators in the
      # future.
      module Conditions
        module SizedComparison
          def valid?
            value.kind_of?(Array) && value.size == 2 && value.last.kind_of?(Integer)
          end

          def typecast(value)
            [super(value[0]), value[1]]
          end
        end

        #--
        # subject.position => ['hello world', 50] # @subject[50] "hello world"
        class PositionComparison < DataMapper::Query::Conditions::AbstractComparison
          include SizedComparison
          slug :position
        end

        #--
        # subject.phrase => 'hello world' # @subject "hello world"
        class PhraseComparison < DataMapper::Query::Conditions::AbstractComparison
          slug :phrase
        end

        #--
        # subject.proximity => ['hello world', 10] # @subject "hello world"~10
        class ProximityComparison < DataMapper::Query::Conditions::AbstractComparison
          include SizedComparison
          slug :proximity
        end

        #--
        # subject.quorum => ['hello world', 10] # @subject "hello world"/10
        class QuorumComparison < DataMapper::Query::Conditions::AbstractComparison
          include SizedComparison
          slug :quorum
        end

        #--
        # subject.exact => 'hello world' # @subject ="hello world"
        class ExactComparison < DataMapper::Query::Conditions::AbstractComparison
          slug :exact
        end
      end # Conditions
    end # Query
  end # Sphinx
end # DataMapper

# core_ext/symbol.rb
class Symbol
  [:position, :phrase, :proximity, :quorum, :exact].each do |sym|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{sym}
        DataMapper::Query::Operator.new(self, #{sym.inspect})
      end
    RUBY
  end
end # class Symbol
