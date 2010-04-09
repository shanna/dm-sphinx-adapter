root  = File.expand_path(File.join(File.dirname(__FILE__), '..'))
files = File.join(root, 'test', 'files')

at_exit do
  system("searchd -c #{files}/sphinx.conf --stop")
end

require File.join(root, 'gems', 'environment')
Bundler.require_env(:development)
require 'test/unit'

begin
  require 'shoulda'
rescue LoadError
  warn 'Shoulda is required for testing. Use gem bundle to install development gems.'
  exit 1
end

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

class Test::Unit::TestCase
  def teardown
    descendants = DataMapper::Model.descendants.dup.to_a
    while model = descendants.shift
      next unless Object.const_defined?(model.name.to_sym)
      descendants.concat(model.descendants) if model.respond_to?(:descendants)
      Object.send(:remove_const, model.name.to_sym)
      DataMapper::Model.descendants.delete(model)
    end
  end
end

