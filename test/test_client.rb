require 'test_adapter'

class TestClient < TestAdapter
  def test_initialize
    assert_nothing_raised { DataMapper::Adapters::Sphinx::Client.new(@config) }
  end

  def test_index
    client = DataMapper::Adapters::Sphinx::Client.new(@config)
    assert_nothing_raised{ client.index }
    assert_nothing_raised{ client.index 'items' }
    assert_nothing_raised{ client.index '*' }
    assert_nothing_raised{ client.index ['items', 'items_delta'] }
  end

  def test_managed_initialize
    assert_nothing_raised { DataMapper::Adapters::Sphinx::ManagedClient.new(@config) }
  end

  def test_search
    begin
      client = DataMapper::Adapters::Sphinx::ManagedClient.new(@config)
      client.index
      assert match = client.search('two')
      assert_equal 1, match[:total]
      assert_equal 2, match[:matches][0][:doc]
    ensure
      client.stop
    end
  end
end # TestClient
