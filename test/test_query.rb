require File.join(File.dirname(__FILE__), 'helper')

class TestQuery < Test::Unit::TestCase
  context 'DM::A::Sphinx::Query' do
    setup do
      # TODO: Unload.
      DataMapper.setup(:query, :adapter => 'sphinx')

      class Resource
        include DataMapper::Resouce
        property :name, String
      end

      @resource   = Resource
      @repository = repository(:query)
    end

    context 'conditions' do
      should 'treat nil operator as extended field match' do
        assert_equal '@name "foo"', query_string(:name => 'foo')
      end

      should 'treat .eql operator as extended field match' do
        assert_equal '@name "foo"', query_string(:name.eql => 'foo')
      end

      should 'treat .like operator as extended field match' do
        assert_equal '@name "foo"', query_string(:name.like => 'foo')
      end

      should 'treat Array as extended field AND match' do
        assert_equal '@name "foo bar"', query_string(:name => %q{foo bar})
      end
    end
  end

  protected
    def query(conditions = {})
      DataMapper::Adapters::Sphinx::Query.new(
        DataMapper::Query.new(@repository, @resource, conditions)
      )
    end

    def query_string(conditions = {})
      query(conditions).to_s
    end
end
