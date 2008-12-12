require 'test/unit'

root = File.join(File.dirname(__FILE__), '..')
lib  = File.join(root, 'lib')
test = File.join(root, 'test')
$:.unshift(lib, test)

require 'dm-sphinx-adapter'

# DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default,
  :adapter  => 'mysql',
  :database => 'dm_sphinx_adapter_test'
)
DataMapper.setup(:search,
  :adapter => 'sphinx',
  :config  => Pathname.new(__FILE__).dirname / 'files' / 'sphinx.conf',
  :managed => true
)

class Test::Unit::TestCase
  def setup
    files   = Pathname.new(__FILE__).dirname / 'files'
    @config = files / 'sphinx.conf'
    db      = files / 'dm_sphinx_adapter_test.sql'

    assert(`mysql5 dm_sphinx_adapter_test < #{db}`.empty?, 'migrate db')
    index
  end

  protected
    def index(*args)
      repository(:search).adapter.client.index(*args)
      sleep 1 # Give sphinx a chance to catch up.
    end
end
