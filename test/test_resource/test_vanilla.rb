require File.join(File.dirname(__FILE__), 'helper')
require 'files/resource_vanilla'
require 'files/resource_storage_name'

class TestVanilla < TestResource
  def test_initialize
    repository(:search) do
      assert_nothing_raised{ Vanilla.new }
      assert_nothing_raised{ StorageName.new }
    end
  end

  def test_all
    repository(:search) do
      assert_equal [{:id => 1}, {:id => 2}, {:id => 3}], Vanilla.all
      assert_equal [{:id => 1}], Vanilla.all(:t_string => 'one')
    end
  end

  def test_all_limit
    repository(:search) do
      assert_equal [{:id => 1}], Vanilla.all(:limit => 1)
      assert_equal [{:id => 1}, {:id => 2}], Vanilla.all(:limit => 2)
    end
  end

  def test_all_offset
    repository(:search) do
      assert_equal [{:id => 1}, {:id => 2}, {:id => 3}], Vanilla.all(:offset => 0)
      assert_equal [{:id => 2}, {:id => 3}], Vanilla.all(:offset => 1)
      assert_equal [], Vanilla.all(:offset => 3)
    end
  end

  def test_first
    repository(:search) do
      assert_equal({:id => 1}, Vanilla.first(:t_string => 'one'))
      assert_nil Vanilla.first(:t_string => 'missing')
    end
  end

  def test_storage_name
    repository(:search) do
      assert_equal Vanilla.all, StorageName.all
      assert_equal Vanilla.first, StorageName.first
    end
  end
end # TestVanilla
