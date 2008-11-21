require 'test_adapter'
require 'files/resource_explicit'

class TestAdapterExplicit < TestAdapter
  def setup
    super
    DataMapper.setup(:search, :adapter => 'sphinx', :config => @config, :managed => true)
  end

  def teardown
    DataMapper.repository(:search).adapter.client.stop
    super
  end

  def test_initialize
    assert_nothing_raised{ Explicit.new }
  end

  def test_search_properties
    assert_equal Explicit.all, Explicit.search
    assert_equal [Explicit.first(:id => 2)], Explicit.search(:name => 'two')
  end

  def test_search_delta
    resource = Explicit.create(:name => 'four', :likes => 'chicken', :updated_on => Time.now)
    DataMapper.repository(:search).adapter.client.index('items_delta')
    assert_equal [resource], Explicit.search(:name => 'four')
  end

  def test_search_attribute_timestamp
    time     = Time.now
    resource = Explicit.create(:name => 'four', :likes => 'chicken', :updated_on => time)
    DataMapper.repository(:search).adapter.client.index('items_delta')

    assert_equal [resource], Explicit.search(:updated_on => time.to_i)
    assert_equal [resource], Explicit.search(:updated_on => (time .. time + 1))
    assert_equal [], Explicit.search(:updated_on => (time - 60 * 60))
    assert_equal [], Explicit.search(:updated_on => (time + 60 * 60))
  end

  def test_search_attribute_boolean
    # TODO:
  end

  def test_search_attribute_integer
    # TODO
  end
end # TestAdapterExplicit
