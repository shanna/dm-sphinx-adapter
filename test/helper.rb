root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require File.join(root, 'gems', 'environment')
Bundler.require_env(:development)
require 'test/unit'

begin
  require 'shoulda'
rescue LoadError
  warn 'Shoulda is required for testing. Use gem bundle to install development gems.'
  exit 1
end

base  = File.join(File.dirname(__FILE__), '..')
files = File.join(base, 'test', 'files')

$:.unshift File.join(base, 'lib')
require 'dm-sphinx-adapter'

class Test::Unit::TestCase
end

# Sphinx runner.
Dir.chdir(base)
begin
  TCPSocket.new('localhost', '9312')
rescue
  puts 'Starting Sphinx...'
  system("searchd --config #{files}/sphinx.conf") || exit
  system('ps aux | grep searchd')
end

indexer = `indexer --config #{files}/sphinx.conf --all --rotate`
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

