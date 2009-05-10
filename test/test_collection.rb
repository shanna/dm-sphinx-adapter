require File.join(File.dirname(__FILE__), 'helper')

class TestAdapter < Test::Unit::TestCase
  context 'DM::A::Sphinx::Collection instance' do
    setup do
      load File.join(File.dirname(__FILE__), 'files', 'model.rb')
      @it       = repository(:search)
      @resource = Item
    end

    should 'have total' do
      assert_equal 3, @it.read_many(query).total
      assert_equal 1, @it.read_many(query(:t_string => 'two')).total
    end

    should 'have words' do
      words = {'two' => {:docs => 1, :hits => 2}}
      assert_equal words, @it.read_many(query(:t_string => 'two')).words
    end
  end

  protected
    def query(conditions = {})
      DataMapper::Query.new(repository(:search), @resource, conditions)
    end
end
