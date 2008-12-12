require File.join(File.dirname(__FILE__), 'helper')

class TestConfig < Test::Unit::TestCase
  def setup
    @log = Pathname.new(__FILE__).dirname / 'var' / 'sphinx.log'
    super
  end

  def test_initialize
    assert_nothing_raised{ config }
    assert_nothing_raised{ config({}) }
    assert_nothing_raised{ config(:config => nil) }
    assert_nothing_raised{ config(:config => 'blah') }
    assert_nothing_raised{ config(:config => @log) }
  end

  def test_initalize_defaults
    assert c = config({})
    assert_equal '0.0.0.0', c.address
    assert_equal 3312, c.port
    assert_equal 'searchd.log', c.log
    assert_raise(RuntimeError){ c.pid_file }
    assert_nil c.config
  end

  def test_initalize_options_hash
    assert c = config(
      :host     => 'options',
      :port     => 1234,
      :log      => 'log.log',
      :pid_file => 'pid.pid'
    )

    assert_equal 'options', c.address
    assert_equal 1234, c.port
    assert_equal 'log.log', c.log
    assert_equal 'pid.pid', c.pid_file
    assert_nil c.config
  end

  def test_initialize_options_string
    assert c = config("sphinx://options:1234")
    assert_equal 'options', c.address
    assert_equal 1234, c.port
    assert_equal 'searchd.log', c.log
    assert_raise(RuntimeError){ c.pid_file }
    assert_nil c.config
  end

  def test_initialize_config
    assert c = config(:config => @config)
    assert_equal 'localhost', c.address
    assert_equal '3312', c.port
    assert_equal 'test/var/sphinx.log', c.log
    assert_equal 'test/var/sphinx.pid', c.pid_file
    assert_equal @config, c.config
  end

  def test_initialize_database_hash
    assert c = config(:database => @config)
    assert_equal @config, c.config
  end

  def test_initialize_database_string
    assert c = config("sphinx://localhost/test/files/sphinx.conf")
    assert_equal @config, c.config
  end

  protected
    def config(options = {:config => @config})
      DataMapper::Adapters::Sphinx::Config.new(options)
    end
end # TestConfig
