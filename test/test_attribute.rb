require File.join(File.dirname(__FILE__), 'helper')

class TestAttributeResource
  include DataMapper::SphinxResource
end

class TestAttribute < Test::Unit::TestCase
  def test_primitive
    assert_nothing_raised do
      TestAttributeResource.class_eval do
        attribute :new_boolean,    TrueClass
        attribute :new_string,     String
        attribute :new_text,       DataMapper::Types::Text
        attribute :new_float,      Float
        attribute :new_integer,    Integer
        attribute :new_bigdecimal, BigDecimal
        attribute :new_datetime,   DateTime
        attribute :new_date,       Date
        attribute :new_time,       Time
        attribute :new_serial,     DataMapper::Types::Serial
      end
    end
  end

  def test_unsupported_primitive
    assert_raise ArgumentError do
      TestAttributeResource.class_eval do
        attribute :name, Test::Unit::TestCase
      end
    end
  end

end # TestAttribute
