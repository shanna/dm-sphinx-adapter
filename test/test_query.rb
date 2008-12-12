require File.join(File.dirname(__FILE__), 'helper')
require 'files/resource_explicit'

class TestQuery < Test::Unit::TestCase
  def test_initialize
    assert_nothing_raised{ query }
    assert_equal '', query.to_s
  end

  def test_eql
    assert_equal '@t_string "foo"',     query(:t_string => 'foo').to_s
    assert_equal '@t_string "foo"',     query(:t_string.eql => 'foo').to_s
    assert_equal '@t_string "foo"',     query(:t_string.like => 'foo').to_s
    assert_equal '@t_string "foo bar"', query(:t_string => %w(foo bar)).to_s
  end

  def test_not
    assert_equal '@t_string -"foo"',     query(:t_string.not => 'foo').to_s
    assert_equal '@t_string -"foo bar"', query(:t_string.not => %w(foo bar)).to_s
  end

  def test_in
    assert_equal '@t_string ("foo" | "bar")', query(:t_string.in => %w{foo bar}).to_s
  end

  def test_and
    # When is DM going to switch conditions to an array? :(
    assert /(?:@t_string "b" )?@t_string "a"(?: @t_string "b")?/.match(query(:t_string.eql => 'a', :t_string.eql => 'b').to_s)
  end

  def test_raw
    assert_equal '"foo bar"~10', query(:conditions => ['"foo bar"~10']).to_s
  end

  protected
    def query(conditions = {})
      DataMapper::Adapters::Sphinx::Query.new(
        DataMapper::Query.new(repository(:search), Explicit, conditions)
      )
    end
end # TestQuery
