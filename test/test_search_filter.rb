require File.join(File.dirname(__FILE__), 'helper')

class FilterTest < Test::Unit::TestCase
  context 'Search' do
    setup do
      class ::Item
        include DataMapper::Resource
        property :id,         Serial
        property :t_string,   String
        property :t_deciaml,  BigDecimal
        property :t_float,    Float
        property :t_integer,  Integer
        property :t_datetime, DateTime
      end
    end

    should 'treat nil operator as equal comparison' do
      filter = filter(:t_integer => 2000).statement
      assert_equal 1, filter.size
      assert_equal 't_integer', filter.first.attribute
      assert_equal [2000], filter.first.values
      assert_equal false, filter.first.exclude
    end

    should 'treat .not opeartor as not operation' do
      filter = filter(:t_integer.not => '2000').statement
      assert_equal 1, filter.size
      assert_equal 't_integer', filter.first.attribute
      assert_equal [2000], filter.first.values
      assert_equal true, filter.first.exclude
    end

    # TODO: Ranges.
  end

  protected
    def filter(conditions = {})
      DataMapper::Sphinx::Search::Filter.new(
        DataMapper::Query.new(::Item.repository, ::Item, conditions)
      )
    end
end

