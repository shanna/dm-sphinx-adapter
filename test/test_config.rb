require 'helper'

class TestConfig < Test::Unit::TestCase
  def setup
    data    = Pathname(__FILE__).dirname.expand_path / 'data'
    @config = data / 'sphinx.conf'
    @log    = data / 'sphinx.log'
  end

  def test_initialize
    assert_nothing_raised{ config_new }
    assert_raise(IOError){ config_new(:config => nil) }
    assert_raise(IOError){ config_new(:config => 'blah') }
    assert_raise(IOError){ config_new(:config => @log) }
  end

  def test_initalize_forms
    assert_nothing_raised{ config_new(:database => @config) }
    # TODO: DataObjects::URI treats /test as the hostname.
    # assert_nothing_raised{ config_new('file://test/data/sphinx.conf') }
    assert_nothing_raised{ config_new('sphinx://localhost/test/data/sphinx.conf') }
  end

  def test_config
    assert_equal @config, config_new.config
  end

  def test_searchd
    assert_kind_of Hash,                 config_new.searchd
    assert_equal 'localhost',            config_new.address
    assert_equal '3312',                 config_new.port
    assert_equal 'test/data/sphinx.pid', config_new.pid_file
    assert_equal 'test/data/sphinx.log', config_new.log
  end

  protected
    def config_new(options = {:config => @config})
      DataMapper::SphinxConfig.new(options)
    end

end # TestConfig
