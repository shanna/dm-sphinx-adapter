require File.join(File.dirname(__FILE__), 'helper')

class QueryTest < Test::Unit::TestCase
  context 'Query' do
    setup do
      class ::Item
        include DataMapper::Resource
        property :id, Serial
      end
    end

    should 'use sphinx query subclass' do
      assert_kind_of DataMapper::Sphinx::Query, query
    end

    should 'allow search mode' do
      assert_nothing_raised do
        assert_kind_of DataMapper::Sphinx::Query, query(:mode => :extended2)
      end
    end
  end

  protected
    def query(conditions = {})
      DataMapper::Query.new(::Item.repository, ::Item, conditions)
    end
end
