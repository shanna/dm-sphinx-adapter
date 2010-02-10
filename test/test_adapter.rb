require File.join(File.dirname(__FILE__), 'helper')

class AdapterTest < Test::Unit::TestCase
  context 'Adapter' do
    setup do
      class ::Item
        include DataMapper::Resource
        property :id,       Serial
        property :t_string, String
        property :t_text,   Text, :lazy => false
      end
      @it = ::Item.repository.adapter
    end

    context 'instance' do
      should 'be adapter intance' do
        assert_kind_of DataMapper::Adapters::SphinxAdapter, @it
        assert_kind_of DataMapper::Sphinx::Adapter, @it
      end

      should 'get all items' do
        assert_equal 3, Item.all.size # should invoke full scan mode.
      end

      should 'be sphinx query' do
        assert_kind_of DataMapper::Sphinx::Query, DataMapper::Query.new(::Item.repository, ::Item, {})
      end
    end
  end
end # AdapterTest
