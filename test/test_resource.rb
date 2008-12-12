require File.join(File.dirname(__FILE__), 'helper')
require 'files/resource_resource'

class TestResource < Test::Unit::TestCase
  def test_initialize
    assert_nothing_raised{ Resource.new }
  end

  def test_search_properties
    assert_equal Resource.all, Resource.search
    assert_equal [Resource.first(:id => 2)], Resource.search(:t_string => 'two')
    assert_equal [Resource.first(:id => 2)], Resource.search(:conditions => ['two'])
  end
end # TestAdapterResource

