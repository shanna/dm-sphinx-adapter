#--
# TODO: Ask about this monkey patch or alternatively I was thinking repository.create_query(*args) which would in turn
# call the same method on the adapter. The command stuff in data objects works the same way so I don't see a good
# argument against it other than the extra dispatch would be slightly slower.
module DataMapper
  class Query
    extend Chainable

    chainable do
      def self.new(*args, &block)
        super
      end
    end
  end # Query
end # DataMapper

# Hijack the DataMapper::Query constructor allowing us to return a subclassed sphinx query object.
module DataMapper
  module Sphinx
    module QueryFactory

      def new(repository, *args)
        if repository.adapter.is_a?(Sphinx::Adapter) && self == DataMapper::Query
          Sphinx::Query.new(repository, *args)
        else
          super
        end
      end
    end # QueryFactory
  end # Sphinx

  class Query
    extend Sphinx::QueryFactory
  end
end # DataMapper

