require 'sphinx_adapter'
require 'test/fixtures/item'
require 'test/unit'

DataMapper::Logger.new(STDOUT, 0)

class SphinxHelper
  def initialize
    @base = File.join(File.dirname(__FILE__), 'data')
    @conf = File.join(@base, 'sphinx.conf')
  end

  def start
    stop if running?
    Dir.chdir(@base){ system 'searchd > /dev/null' }
    sleep 2 # Give it a chance.
    running? or raise "Sphinx searchd daemon failed to start."
  end

  def stop
    system "kill #{pid}" if running?
  end

  def index
    cmd = "indexer --all"
    cmd << ' --rotate' if running?
    cmd << ' > /dev/null'
    Dir.chdir(@base){ system cmd }
  end

  def pid
    File.open(File.join(@base, 'sphinx.pid')).read.strip rescue nil
  end

  def running?
    pid && !pid.empty? && `ps -p #{pid} | wc -l`.to_i > 1
  end
end

module TestHelper
  def sphinx
    @sphinx ||= SphinxHelper.new
  end
end

# Lesser of two evils?
Test::Unit::TestCase.send(:include, TestHelper)
