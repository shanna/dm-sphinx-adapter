require File.join(File.dirname(__FILE__), 'helper')

describe 'Search Extended2' do
  def search conditions = {}
    DataMapper::Sphinx::Search::Extended2.new(
      DataMapper::Sphinx::Query.new(::Item.repository, ::Item, conditions)
    )
  end

  before do
    class ::Item
      include DataMapper::Resource
      property :id,       Serial
      property :t_string, String
      property :t_text,   Text, :lazy => false
    end
  end

  it 'should treat nil operator as equal comparison' do
    search = search(:t_string => 'foo')
    assert_equal '(@t_string foo)', search.statement
  end

  it 'should treat position operator as position comparison' do
    search = search(:t_string.position => ['foo', 2])
    assert_equal '(@t_string[2] "foo")', search.statement
  end

  it 'should treat phrase operator as phrase comparison' do
    search = search(:t_string.phrase => 'foo bar')
    assert_equal '(@t_string "foo bar")', search.statement
  end

  it 'should treat proximity operator as proximity comparison' do
    search = search(:t_string.proximity => ['foo bar', 2])
    assert_equal '(@t_string "foo bar"~2)', search.statement
  end

  it 'should treat quorum operator as quorum comparison' do
    search = search(:t_string.quorum => ['foo bar', 2])
    assert_equal '(@t_string "foo bar"/2)', search.statement
  end

  it 'should treat exact operator as exact comparison' do
    search = search(:t_string.exact => 'foo')
    assert_equal '(@t_string ="foo")', search.statement
  end

  it 'should treat Array as inclusion comparison' do
    search = search(:t_string => %w{foo bar})
    assert_equal '(@t_string (foo|bar))', search.statement
  end

  it 'should treat .not opeartor as not operation' do
    search = search(:t_string.not => 'foo')
    assert_equal '(!(@t_string foo))', search.statement
  end

  it 'should treat Array .not operator as not operation of inclusion comparison' do
    search = search(:t_string.not => %w{foo bar})
    assert_equal '(!(@t_string (foo|bar)))', search.statement
  end

  it 'should handle raw conditions' do
    search = search(:conditions => ['@* foo'])
    assert_equal '(@* foo)', search.statement
  end

  # TODO: Test 'and', 'or' connective operators.
end

