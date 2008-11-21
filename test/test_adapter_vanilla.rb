require 'test_adapter'
require 'files/resource_vanilla'
require 'files/resource_storage_name'

class TestAdapterVanilla < TestAdapter
  def setup
    super
    DataMapper.setup(:default, :adapter => 'sphinx', :config => @config, :managed => true)
  end

  def teardown
    DataMapper.repository(:default).adapter.client.stop
    super
  end

  def test_initialize
    assert_nothing_raised{ Vanilla.new }
    assert_nothing_raised{ StorageName.new }
  end

  def test_all
    assert_equal [{:id => 1}, {:id => 2}, {:id => 3}], Vanilla.all
    assert_equal [{:id => 1}], Vanilla.all(:name => 'one')
  end

  def test_all_limit
    assert_equal [{:id => 1}], Vanilla.all(:limit => 1)
    assert_equal [{:id => 1}, {:id => 2}], Vanilla.all(:limit => 2)
  end

  def test_all_offset
    assert_equal [{:id => 1}, {:id => 2}, {:id => 3}], Vanilla.all(:offset => 0)
    assert_equal [{:id => 2}, {:id => 3}], Vanilla.all(:offset => 1)
    assert_equal [], Vanilla.all(:offset => 3)
  end

  def test_first
    assert_equal({:id => 1}, Vanilla.first(:name => 'one'))
    assert_nil Vanilla.first(:name => 'missing')
  end

  def test_storage_name
    assert_equal Vanilla.all, StorageName.all
    assert_equal Vanilla.first, StorageName.first
  end
end
