require 'test_adapter'
require 'files/resource_resource'

class TestAdapterResource < TestAdapter
  def setup
    super
    DataMapper.setup(:search, :adapter => 'sphinx', :config => @config, :managed => true)
  end

  def teardown
    DataMapper.repository(:search).adapter.client.stop
    super
  end

  def test_initialize
    assert_nothing_raised{ Resource.new }
  end

  def test_search_properties
    assert_equal Resource.all, Resource.search
    assert_equal [Resource.first(:id => 2)], Resource.search(:name => 'two')
    assert_equal [Resource.first(:id => 2)], Resource.search(:conditions => ['two'])
  end
end # TestAdapterResource

