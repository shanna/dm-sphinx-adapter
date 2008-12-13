$VERBOSE = false # Shitloads of warnings in dm :(
require 'rubygems'
require 'extlib'
require 'extlib/hook'
require 'pathname'
require 'shoulda'
require 'test/unit'

base = Pathname.new(__FILE__).dirname + '..'
%w{lib test}.each{|p| $:.unshift base + p}

require 'dm-sphinx-adapter'

# Sphinx runner.
Dir.chdir(base)
config = base + 'test' + 'files' + 'mysql5.sphinx.conf'
begin
  TCPSocket.new('localhost', '3312')
rescue
  puts 'Starting Sphinx...'
  system("searchd --config #{config}") || exit
  system('ps aux | grep searchd')
end

class Test::Unit::TestCase
  include Extlib::Hook

  before :setup do
    files = Pathname.new(__FILE__).dirname + 'files'

    mysql = `mysql5 dm_sphinx_adapter_test < #{files + 'mysql5.sql'} 2>&1`
    raise %{Re-create database failed:\n #{mysql}} unless mysql.blank?

    indexer = `indexer --config #{files + 'mysql5.sphinx.conf'} --all --rotate`
    raise %{Re-create index failed:\n #{indexer}} if indexer =~ /error|fatal/i

    DataMapper.setup(:default, :adapter => 'mysql', :database => 'dm_sphinx_adapter_test')
    sleep 1; # Give sphinx a chance to catch up before test runs.
  end

  # after :teardown do
  def teardown
    descendants = DataMapper::Resource.descendants.dup.to_a
    while model = descendants.shift
      descendants.concat(model.descendants) if model.respond_to?(:descendants)
      Object.send(:remove_const, model.name.to_sym)
      DataMapper::Resource.descendants.delete(model)
    end
  end
end

