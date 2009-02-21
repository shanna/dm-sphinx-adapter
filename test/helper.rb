$VERBOSE = false # Shitloads of warnings in dm :(
require 'rubygems'
require 'extlib'
require 'extlib/hook'
require 'pathname'
require 'shoulda'
require 'test/unit'

base  = Pathname.new(__FILE__).dirname + '..'
files = base + 'test' + 'files'
%w{lib test}.each{|p| $:.unshift base + p}

require 'dm-sphinx-adapter'

# Sphinx runner.
Dir.chdir(base)
begin
  TCPSocket.new('localhost', '3312')
rescue
  puts 'Starting Sphinx...'
  system("searchd --config #{files + 'sphinx.conf'}") || exit
  system('ps aux | grep searchd')
end

indexer = `indexer --config #{files + 'sphinx.conf'} --all --rotate`
raise %{Re-create index failed:\n #{indexer}} if indexer =~ /error|fatal/i
sleep 1

# :default is unused at the moment.
DataMapper.setup(:default, :adapter => 'in_memory', :database => 'dm_sphinx_adapter_test')
DataMapper.setup(:search,  :adapter => 'sphinx')

class Test::Unit::TestCase
  include Extlib::Hook

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

