require 'dm-sphinx-adapter'
require 'test/unit'

# DataMapper::Logger.new(STDOUT, :debug)

class TestAdapter < Test::Unit::TestCase
  def setup
    # TODO: A little too brutal even by my standards.
    Dir.chdir(File.join(File.dirname(__FILE__), 'files')) do
      system 'mysql -u root dm_sphinx_adapter_test < dm_sphinx_adapter_test.sql' \
        or raise %q{Tests require the dm_sphinx_adapter_test database.}
    end

    DataMapper.setup(:default, 'mysql://localhost/dm_sphinx_adapter_test')

    @config = Pathname.new(__FILE__).dirname.expand_path / 'files' / 'sphinx.conf'
    @client = DataMapper::Adapters::Sphinx::ManagedClient.new(:config => @config)
    @client.index
    sleep 1
  end

  def test_unmanaged_setup
    assert DataMapper.setup(:sphinx, :adapter => 'sphinx')
    assert_kind_of DataMapper::Adapters::SphinxAdapter, repository(:sphinx).adapter
    assert_kind_of DataMapper::Adapters::Sphinx::Client, repository(:sphinx).adapter.client
  end

  def test_managed_setup
    assert DataMapper.setup(:sphinx, :adapter => 'sphinx', :config => @config, :managed => true)
    assert_kind_of DataMapper::Adapters::SphinxAdapter, repository(:sphinx).adapter
    assert_kind_of DataMapper::Adapters::Sphinx::ManagedClient, repository(:sphinx).adapter.client
  end

  def teardown
    @client.stop
    sleep 1
  end
end
