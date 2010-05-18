require File.join(File.dirname(__FILE__), 'helper')

describe 'Search All' do
  def search conditions = {}
    DataMapper::Sphinx::Search::All.new(
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
    assert_equal 'foo', search.statement
  end

  it 'should allow and connective operator' do
    search = search(:t_string => 'foo', :t_text => 'bar')
    assert search.statement =~ /foo bar|bar foo/
  end

  it 'should handle raw conditions' do
    search = search(:conditions => ['foo'])
    assert_equal 'foo', search.statement
  end
end

