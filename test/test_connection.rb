require 'helper'

class TestConnection < Test::Unit::TestCase
  def setup
    # TODO: A little too brutal for me.
    Dir.chdir(File.join(File.dirname(__FILE__), 'fixtures')) do
      system 'mysql -u root dm_sphinx_adapter_test < item.sql' \
        or raise %q{Tests require the dm_sphinx_adapter_test.items table.}
    end
  end

  def test_database_connection
    assert DataMapper.setup(:default, 'mysql://localhost/dm_sphinx_adapter_test')
    assert DataMapper.setup(:search,  'sphinx://localhost')
  end

  def test_sphinx_connection
    assert sphinx.index
    assert sphinx.start
    assert sphinx.running?
  end
end # TestConnection
