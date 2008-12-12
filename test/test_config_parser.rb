require File.join(File.dirname(__FILE__), 'helper')

class TestConfigParser < Test::Unit::TestCase
  def setup
    @log = Pathname.new(__FILE__).dirname / 'var' / 'sphinx.log'
    super
  end

  def test_parse
    assert_nothing_raised{ parse }
    assert_raise(Errno::ENOENT){ parse('blah') }
    assert_raise(RuntimeError){ parse(@log) }
    assert_kind_of Hash, parse
  end

  def test_searchd_host
    assert_equal 'localhost', parse['address']
  end

  def test_searchd_port
    assert_equal '3312', parse['port']
  end

  def test_searchd_pid_file
    assert_equal 'test/var/sphinx.pid', parse['pid_file']
  end

  def test_searchd_log
    assert_equal 'test/var/sphinx.log', parse['log']
  end

  protected
    def parse(config = @config)
      DataMapper::Adapters::Sphinx::ConfigParser.parse(config)
    end
end # TestConfigParser
