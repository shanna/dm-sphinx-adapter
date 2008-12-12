require File.join(File.dirname(__FILE__), 'helper')

class TestAdapter < Test::Unit::TestCase

  def test_unmanaged_setup
    assert DataMapper.setup(:sphinx, :adapter => 'sphinx', :config => @config)
    assert_kind_of DataMapper::Adapters::SphinxAdapter, repository(:sphinx).adapter
    assert_kind_of DataMapper::Adapters::Sphinx::Client, repository(:sphinx).adapter.client
  end

  def test_managed_setup
    assert DataMapper.setup(:sphinx, :adapter => 'sphinx', :config => @config, :managed => true)
    assert_kind_of DataMapper::Adapters::SphinxAdapter, repository(:sphinx).adapter
    assert_kind_of DataMapper::Adapters::Sphinx::ManagedClient, repository(:sphinx).adapter.client
  end

end # TestAdapter
