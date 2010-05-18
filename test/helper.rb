root  = File.expand_path(File.join(File.dirname(__FILE__), '..'))
files = File.join(root, 'test', 'files')

#at_exit do
#  system("searchd -c #{files}/sphinx.conf --stop")
#end

require File.join(root, 'gems', 'environment')
Bundler.require_env(:development)

require 'minitest/unit'
require 'minitest/spec'
require File.join(root, 'test/lib/minitest/pretty')

$:.unshift File.join(root, 'lib')
require 'dm-sphinx-adapter'

# Sphinx runner.
Dir.chdir(root)
begin
  TCPSocket.new('localhost', '9312')
rescue
  puts 'Starting Sphinx...'
  system("searchd -c #{files}/sphinx.conf") || exit
  system('ps aux | grep searchd')
end

indexer = `indexer -c #{files}/sphinx.conf --all --rotate`
raise %{Re-create index failed:\n #{indexer}} if indexer =~ /error|fatal/i
sleep 1

# DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, :adapter => 'sphinx')

# Use DM shared spec model cleanup code.
require 'dm-core/spec/lib/spec_helper'
class MiniTest::Unit::TestCase
  def teardown
    ::DataMapper::Spec.cleanup_models
  end
end

