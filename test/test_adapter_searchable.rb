require 'test_adapter'
require 'files/resource_searchable'

class TestAdapterSearchable < TestAdapter
  def setup
    super
    DataMapper.setup(:search, :adapter => 'sphinx', :config => @config, :managed => true)
  end

  def teardown
    DataMapper.repository(:search).adapter.client.stop
    super
  end

  def test_initialize
    assert_nothing_raised{ Searchable.new }
  end

  def test_search
    assert_equal Searchable.all, Searchable.search
    assert_equal [Searchable.first(:id => 2)], Searchable.search(:name => 'two')
  end
end # TestAdapterSearchable
