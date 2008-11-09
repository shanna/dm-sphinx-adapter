require 'helper'

class TestClient < Test::Unit::TestCase
  def setup
    @config = Pathname.new(__FILE__).dirname.expand_path / 'data' / 'sphinx.conf'

    # TODO: A little too brutal for me.
    Dir.chdir(File.join(File.dirname(__FILE__), 'fixtures')) do
      system 'mysql -u root dm_sphinx_adapter_test < item.sql' \
        or raise %q{Tests require the dm_sphinx_adapter_test.items table.}
    end
  end

  def test_initialize
    assert_nothing_raised do
      DataMapper::SphinxClient.new(@config)
    end
  end

  def test_index
    client = DataMapper::SphinxClient.new(@config)
    assert_nothing_raised{ client.index }
    assert_nothing_raised{ client.index 'items' }
    assert_nothing_raised{ client.index '*' }
    assert_nothing_raised{ client.index ['items', 'items_delta'] }
  end

  def test_managed_initialize
    assert_nothing_raised do
      DataMapper::SphinxManagedClient.new(@config)
    end
  end

  def test_search
    begin
      client = DataMapper::SphinxManagedClient.new(@config)
      client.index
      assert client.search('foo')
    ensure
      client.stop
    end
  end
end # TestClient
