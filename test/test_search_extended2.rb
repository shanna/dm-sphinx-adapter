require File.join(File.dirname(__FILE__), 'helper')

class SearchTest < Test::Unit::TestCase
  context 'Search' do
    setup do
      class ::Item
        include DataMapper::Resource
        property :id,       Serial
        property :t_string, String
        property :t_text,   Text, :lazy => false
      end
    end

    should 'treat nil operator as equal comparison' do
      search = search(:t_string => 'foo')
      assert_equal '(@t_string foo)', search.statement
    end

    should 'treat position operator as position comparison' do
      search = search(:t_string.position => ['foo', 2])
      assert_equal '(@t_string[2] "foo")', search.statement
    end

    should 'treat phrase operator as phrase comparison' do
      search = search(:t_string.phrase => 'foo bar')
      assert_equal '(@t_string "foo bar")', search.statement
    end

    should 'treat proximity operator as proximity comparison' do
      search = search(:t_string.proximity => ['foo bar', 2])
      assert_equal '(@t_string "foo bar"~2)', search.statement
    end

    should 'treat quorum operator as quorum comparison' do
      search = search(:t_string.quorum => ['foo bar', 2])
      assert_equal '(@t_string "foo bar"/2)', search.statement
    end

    should 'treat exact operator as exact comparison' do
      search = search(:t_string.exact => 'foo')
      assert_equal '(@t_string ="foo")', search.statement
    end

    should 'treat Array as inclusion comparison' do
      search = search(:t_string => %w{foo bar})
      assert_equal '(@t_string (foo|bar))', search.statement
    end

    should 'treat .not opeartor as not operation' do
      search = search(:t_string.not => 'foo')
      assert_equal '(!(@t_string foo))', search.statement
    end

    should 'treat Array .not operator as not operation of inclusion comparison' do
      search = search(:t_string.not => %w{foo bar})
      assert_equal '(!(@t_string (foo|bar)))', search.statement
    end

    should 'handle raw conditions' do
      search = search(:conditions => ['@* foo'])
      assert_equal '(@* foo)', search.statement
    end

    # TODO: Test 'and', 'or' connective operators.
  end

  protected
    def search(conditions = {})
      DataMapper::Sphinx::Search::Extended2.new(
        DataMapper::Query.new(::Item.repository, ::Item, conditions)
      )
    end
end

