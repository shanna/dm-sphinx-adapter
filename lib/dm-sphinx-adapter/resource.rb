module DataMapper
  module Adapters
    module Sphinx

      ##
      # Declare Sphinx indexes in your resource.
      #
      #   model Items
      #     include DataMapper::SphinxResource
      #
      #     # .. normal properties and such for :default
      #
      #     repository(:search) do
      #       # Query some_index, some_index_delta in that order.
      #       index :some_index
      #       index :some_index_delta, :delta => true
      #
      #       # Sortable by some attributes.
      #       attribute :updated_at, DateTime  # sql_attr_timestamp
      #       attribute :age, Integer          # sql_attr_uint
      #       attribute :deleted, Boolean      # sql_attr_bool
      #     end
      #   end
      module Resource
        def self.included(model) #:nodoc:
          model.class_eval do
            include DataMapper::Resource
            extend ClassMethods
          end
        end

        module ClassMethods
          def self.extended(model) #:nodoc:
            model.instance_variable_set(:@sphinx_indexes, {})
            model.instance_variable_set(:@sphinx_attributes, {})
          end

          ##
          # Defines a sphinx index on the resource.
          #
          # Indexes are naturally ordered, with delta indexes at the end of the list so that duplicate document IDs in
          # delta indexes override your main indexes.
          #
          # @param [Symbol] name the name of a sphinx index to search for this resource
          # @param [Hash(Symbol => String)] options a hash of available options
          # @see   DataMapper::Adapters::Sphinx::Index
          def index(name, options = {})
            index   = Index.new(self, name, options)
            indexes = sphinx_indexes(repository_name)
            indexes << index

            # TODO: I'm such a Ruby nub. In the meantime I've gone back to my Perl roots.
            # This is a Schwartzian transform to sort delta indexes to the bottom and natural sort by name.
            mapped  = indexes.map{|i| [(i.delta? ? 1 : 0), i.name, i]}
            sorted  = mapped.sort{|a, b| a[0] <=> b[0] || a[1] <=> b[1]}
            indexes.replace(sorted.map{|i| i[2]})

            index
          end

          ##
          # List of declared sphinx indexes for this model.
          def sphinx_indexes(repository_name = default_repository_name)
            @sphinx_indexes[repository_name] ||= []
          end

          ##
          # Defines a sphinx attribute on the resource.
          #
          # @param [Symbol] name the name of a sphinx attribute to order/restrict by for this resource
          # @param [Class] type the type to define this attribute as
          # @param [Hash(Symbol => String)] options a hash of available options
          # @see   DataMapper::Adapters::Sphinx::Attribute
          def attribute(name, type, options = {})
            # Attributes are just properties without a getter/setter in the model.
            # This keeps DataMapper::Query happy when building queries.
            attribute = Sphinx::Attribute.new(self, name, type, options)
            properties(repository_name)[attribute.name] = attribute
            attribute
          end

          ##
          # List of declared sphinx attributes for this model.
          def sphinx_attributes(repository_name = default_repository_name)
            properties(repository_name).grep{|p| p.kind_of? Sphinx::Attribute}
          end

        end # ClassMethods
      end # Resource
    end # Sphinx
  end # Adapters

  # Follow DM naming convention.
  SphinxResource = Adapters::Sphinx::Resource
end # DataMapper

