require File.join(File.dirname(__FILE__), 'helper')

describe 'Adapter' do
  before do
    class ::Item
      include DataMapper::Resource
      property :id,       Serial
    end
    @it = ::Item.repository.adapter
  end

  it 'should be adapter intance' do
    assert_kind_of DataMapper::Adapters::SphinxAdapter, @it
    assert_kind_of DataMapper::Sphinx::Adapter, @it
  end

  it 'should invoke full scan (*) mode' do
    assert_equal 3, Item.all.size
  end
end
