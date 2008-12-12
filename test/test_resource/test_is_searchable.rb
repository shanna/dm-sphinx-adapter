require File.join(File.dirname(__FILE__), 'helper')
require 'files/resource_is_searchable'

class TestSearchable < TestResource
  def test_initialize
    assert_nothing_raised{ Searchable.new }
  end

  def test_search
    assert_equal Searchable.all, Searchable.search
    assert_equal [Searchable.first(:id => 2)], Searchable.search(:t_string => 'two')
  end
end # TestSearchable
