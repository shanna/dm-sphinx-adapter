require File.join(File.dirname(__FILE__), 'helper')

class TestIndex < Test::Unit::TestCase
  context 'DM::A::Sphinx::Index instance' do
    should 'respond to delta?'
  end

  context 'DM::A::Sphinx::Resource class' do
    setup do
      class ::Resource
        include DataMapper::SphinxResource
      end
    end

    context '#index method' do
      should 'append an index' do
        assert_nothing_raised do
          Resource.class_eval do
            index :name
          end
        end
      end
    end

    context '#sphinx_indexes method' do
      should 'return DM::A::Sphinx::Index objects'
      should 'return delta indexes at the end of the list'
    end
  end
end
