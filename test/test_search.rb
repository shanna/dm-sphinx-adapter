require 'helper'

class TestSearch < Test::Unit::TestCase
  def setup
    # TODO: A little too brutal for me.
    Dir.chdir(File.join(File.dirname(__FILE__), 'fixtures')) do
      system 'mysql -u root dm_sphinx_adapter_test < item.sql' \
        or raise %q{Tests require the dm_sphinx_adapter_test.items table.}
    end

    @config = Pathname.new(__FILE__).dirname.expand_path / 'data' / 'sphinx.conf'
    DataMapper.setup(:default, 'mysql://localhost/dm_sphinx_adapter_test')
    DataMapper.setup(:search,
      :adapter => 'sphinx',
      :config  => @config,
      :managed => true
    )
  end

  def teardown
    DataMapper.repository(:search).adapter.client.stop
    # You can also build a new client with the same config and call stop on that.
    # client = DataMapper::SphinxManagedClient.new(@config)
    # client.stop
  end

  def test_search
    assert_nothing_raised{ Item.search }
    assert_nothing_raised{ Item.search(:name => 'foo') }
  end

  def test_search_resource_only
    assert_nothing_raised{ ItemResourceOnly.search }
    assert_nothing_raised{ ItemResourceOnly.search(:name => 'foo') }
  end

  def test_search_resource_explicit
    assert_nothing_raised{ ItemResourceExplicit.search }
    assert_nothing_raised{ ItemResourceExplicit.search(:name => 'foo') }
  end

  def test_search_attributes
    # Attributes that exist only in :search and the sphinx.
    assert_nothing_raised do
      ItemResourceExplicit.search(:updated => (Time.now - 10 .. Time.now + 10))
    end
  end
end # TestSearch
