require 'test/unit'
require 'dm-sphinx-adapter'

class TestConfigParser < Test::Unit::TestCase
  def setup
    base    = Pathname(__FILE__).dirname.expand_path
    @config = base / 'files' / 'sphinx.conf'
    @log    = base / 'var' / 'sphinx.log'
  end

  def test_parse
    assert_nothing_raised{ parse }
    assert_raise(Errno::ENOENT){ parse('blah') }
    assert_raise(RuntimeError){ parse(@log) }
  end

  def test_searchd
    assert_kind_of Hash, searchd = parse
    assert_equal 'localhost',           searchd['address']
    assert_equal '3312',                searchd['port']
    assert_equal 'test/var/sphinx.pid', searchd['pid_file']
    assert_equal 'test/var/sphinx.log', searchd['log']
  end

  protected
    def parse(config = @config)
      DataMapper::Adapters::Sphinx::ConfigParser.parse(config)
    end
end # TestConfigParser
