require File.join(File.dirname(__FILE__), 'helper')

class TestResource < Test::Unit::TestCase
  context 'DM::A::Sphinx::Resource module' do
    setup do
      class ::Resource
        include DataMapper::SphinxResource
      end
    end

    [:index, :sphinx_indexes, :attribute, :sphinx_attributes].each do |method|
      should "respond to #{method}" do
        assert_respond_to Resource, method
      end
    end
  end
end
