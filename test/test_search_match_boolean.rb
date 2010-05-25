require File.join(File.dirname(__FILE__), 'helper')

describe 'Search Boolean' do
  def search conditions = {}
    DataMapper::Sphinx::Search::Match::Boolean.new(
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
    assert_equal '(foo)', search.statement
  end

  it 'should treat .not opeartor as not operation' do
    search = search(:t_string.not => 'foo')
    assert_equal '(!(foo))', search.statement
  end

  it 'should treat Array .not operator as not operation of inclusion comparison' do
    search = search(:t_string.not => %w{foo bar})
    assert_equal '(!(foo|bar))', search.statement
  end

  it 'should handle raw conditions' do
    search = search(:conditions => ['foo'])
    assert_equal '(foo)', search.statement
  end

  # TODO: Test 'and', 'or' connective operators.
end

