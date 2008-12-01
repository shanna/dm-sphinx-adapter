require 'test/unit'
require 'dm-sphinx-adapter'
require 'files/resource_explicit'

class TestQuery < Test::Unit::TestCase
  def setup
    DataMapper.setup(:default, :adapter => 'sphinx')
    @repository = repository(:default)
  end

  def test_initialize
    assert_nothing_raised{ query }
    assert_equal '', query.to_s
  end

  def test_eql
    assert_equal '@name "foo"',     query(:name => 'foo').to_s
    assert_equal '@name "foo"',     query(:name.eql => 'foo').to_s
    assert_equal '@name "foo"',     query(:name.like => 'foo').to_s
    assert_equal '@name "foo bar"', query(:name => %w(foo bar)).to_s
  end

  def test_not
    assert_equal '@name -"foo"',     query(:name.not => 'foo').to_s
    assert_equal '@name -"foo bar"', query(:name.not => %w(foo bar)).to_s
  end

  def test_in
    assert_equal '@name ("foo" | "bar")', query(:name.in => %w{foo bar}).to_s
  end

  def test_and
    # When is DM going to switch conditions to an array? :(
    assert /(?:@name "b" )?@name "a"(?: @name "b")?/.match(query(:name.eql => 'a', :name.eql => 'b').to_s)
  end

  def test_raw
    assert_equal '"foo bar"~10', query(:conditions => ['"foo bar"~10']).to_s
  end

  protected
    def query(conditions = {})
      DataMapper::Adapters::Sphinx::Query.new(
        DataMapper::Query.new(@repository, Explicit, conditions)
      )
    end
end # TestQuery
