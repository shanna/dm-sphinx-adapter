require File.join(File.dirname(__FILE__), 'helper')

class TestAdapter < Test::Unit::TestCase
  context 'DM::A::Sphinx::Adapter class' do
    setup do
      DataMapper.setup(:adapter, :adapter => 'sphinx', :config  => @config)

      require File.join(File.dirname(__FILE__), 'files', 'model')
      @it       = repository(:adapter)
      @resource = Item
    end

    context '#create' do
      should 'should return zero records created' do
        assert_equal 0, @it.create(resource)
      end
    end
  end

  protected
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
      @resource.create(resource(options).attributes.except(:id))
    end
end
