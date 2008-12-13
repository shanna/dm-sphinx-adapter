require File.join(File.dirname(__FILE__), 'helper')

class TestAdapter < Test::Unit::TestCase
  context 'DM::A::Sphinx::Adapter class' do
    setup do
      DataMapper.setup(:adapter, :adapter => 'sphinx')
      load File.join(File.dirname(__FILE__), 'files', 'model.rb')
      @it       = repository(:adapter)
      @resource = Item
    end

    context '#create' do
      should 'should return zero records created' do
        assert_equal 0, @it.create(create_resource)
      end
    end

    context '#delete' do
      should 'should return zero records deleted' do
        assert_equal 0, @it.delete(create_resource)
      end
    end

    context '#read_many' do
      context 'conditions' do
        should 'return all objects when nil' do
          assert_equal [{:id => 1}, {:id => 2}, {:id => 3}], @it.read_many(query)
        end

        should 'return subset of objects for conditions' do
          assert_equal [{:id => 2}], @it.read_many(query(:t_string => 'two'))
        end
      end

      context 'offsets' do
        should 'be able to offset the objects' do
          assert_equal [{:id => 1}, {:id => 2}, {:id => 3}], @it.read_many(query(:offset => 0))
          assert_equal [{:id => 2}, {:id => 3}], @it.read_many(query(:offset => 1))
          assert_equal [], @it.read_many(query(:offset => 3))
        end
      end

      context 'limits' do
        should 'be able to limit the objects' do
          assert_equal [{:id => 1}], @it.read_many(query(:limit => 1))
          assert_equal [{:id => 1}, {:id => 2}], @it.read_many(query(:limit => 2))
        end
      end
    end

    context '#read_one' do
      should 'return the first object of a #read_many' do
        assert_equal @it.read_many(query).first, @it.read_one(query)

        query = query(:t_string => 'two')
        assert_equal @it.read_many(query).first, @it.read_one(query)
      end
    end
  end

  protected
    def query(conditions = {})
      DataMapper::Query.new(repository(:adapter), @resource, conditions)
    end

    def resource(options = {})
      now = Time.now
      attributes = {
        :t_string   => now.to_s,
        :t_text     => "text #{now.to_s}!",
        :t_decimal  => now.to_i * 0.001,
        :t_float    => now.to_i * 0.0001,
        :t_integer  => now.to_i,
        :t_datetime => now
      }.update(options)
      @resource.new(attributes)
    end

    def create_resource(options = {})
      repository(:adapter) do
        @resource.create(resource(options).attributes.except(:id))
      end
    end
end
