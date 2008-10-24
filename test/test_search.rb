require 'helper'

class TestSearch < Test::Unit::TestCase
  def setup
    # TODO: A little too brutal for me.
    Dir.chdir(File.join(File.dirname(__FILE__), 'fixtures')) do
      system 'mysql -u root dm_sphinx_adapter_test < item.sql' \
        or raise %q{Tests require the dm_sphinx_adapter_test.items table.}
    end

    sphinx.start
  end

  def test_search_without_arguments
    assert_nothing_raised{ Item.search }
  end

  def test_search_extended
    assert_nothing_raised{ Item.search(:name => 'foo') }
  end
end # TestSearch
