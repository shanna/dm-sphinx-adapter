require File.join(File.dirname(__FILE__), 'helper')
require 'files/resource_explicit'

class TestExplicit < TestResource
  def test_initialize
    assert_nothing_raised{ Explicit.new }
  end

  def test_search_properties
    assert_equal Explicit.all, Explicit.search
    assert_equal [Explicit.first(:id => 2)], Explicit.search(:t_string => 'two')
  end

  def test_search_delta
    resource = create(:t_string => 'four')
    index_delta

    assert_equal [resource], Explicit.search(:t_string => 'four')
  end

  def test_search_attribute_datetime
    time     = Time.now
    resource = create(:t_datetime => time)
    index_delta

    assert_equal [resource], Explicit.search(:t_datetime => time)
    assert_equal [resource], Explicit.search(:t_datetime => (time .. time + 1))
    assert_equal [], Explicit.search(:t_datetime => (time - 60 * 60))
    assert_equal [], Explicit.search(:t_datetime => (time + 60 * 60))
  end

  def test_search_attribute_bigdecimal
    resource = create(:t_decimal => '15.00')
    index_delta

    assert_equal [resource], Explicit.search(:t_decimal => (14.00 .. 16.00)).to_a
  end

  protected
    def create(options = {})
      now        = Time.now
      attributes = {
        :t_string   => now.to_s,
        :t_text     => "text #{now.to_s}!",
        :t_decimal  => now.to_i * 0.001,
        :t_float    => now.to_i * 0.0001,
        :t_integer  => now.to_i,
        :t_datetime => now
      }.update(options)

      Explicit.create(attributes)
    end

    def index_delta
      repository(:search).adapter.client.index('items_delta')
      sleep 1 # Give sphinx a chance.
    end
end # TestExplicit
