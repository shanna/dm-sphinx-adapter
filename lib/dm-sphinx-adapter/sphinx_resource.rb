module DataMapper
  module SphinxResource
    def self.included(model)
      model.class_eval do
        include DataMapper::Resource
        extend ClassMethods
      end
    end

    module ClassMethods
      def self.extended(model)
        model.instance_variable_set(:@sphinx_indexes, {})
      end

      ##
      # defines a sphinx index on the resource
      #
      # @param <Symbol> name the name of a sphinx index to search for this resource
      # @param <Hash(Symbol => String)> options a hash of available options
      # @see   DataMapper::SphinxIndex
      def index(name, options = {})
        index   = SphinxIndex.new(self, name, options)
        indexes = sphinx_indexes(repository_name)
        indexes << index

        # TODO: I'm such a Ruby nub. In the meantime I've gone back to my Perl roots.
        # This is a Schwartzian transform to sort delta indexes to the bottom and natural sort by name.
        mapped  = indexes.map{|i| [(i.delta? ? 1 : 0), i.name, i]}
        sorted  = mapped.sort{|a, b| a[0] <=> b[0] || a[1] <=> b[1]}
        indexes.replace(sorted.map{|i| i[2]})

        index
      end

      def sphinx_indexes(repository_name = default_repository_name)
        @sphinx_indexes[repository_name] ||= []
      end

    end # ClassMethods
  end # SphinxResource
end # DataMapper

