require File.join(File.dirname(__FILE__), 'helper')

class TestAttribute < Test::Unit::TestCase
  context 'DM::A::Sphinx::Attribute instance' do
    should 'typecast DateTime to Integer'
    should 'typecast Date to Integer'
    should 'typecast Time to Integer'
    should 'typecast BigDecimal to Float'
  end

  context 'DM::A::Sphinx::Resource#attribute class method' do
    setup do
      class ::Resource
        include DataMapper::SphinxResource
      end
    end

    DataMapper::Adapters::Sphinx::Attribute::TYPES.each do |type|
      should "accept a #{type} type" do
        assert_nothing_raised do
          Resource.class_eval do
            attribute :name, type
          end
        end
      end
    end

    should 'raise ArgumentError for unsupported type' do
      assert_raise(ArgumentError) do
        Resource.class_eval do
          attribute :name, Test::Unit::TestCase
        end
      end
    end
  end
end
