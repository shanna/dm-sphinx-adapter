module DataMapper
  module Adapters
    module Sphinx

      # Sphinx index definition.
      class Index
        include Assertions

        # Options.
        attr_reader :model, :name, :options

        # ==== Parameters
        # model<DataMapper::Model>:: Your resources model.
        # name<Symbol, String>:: The index name.
        # options<Hash>:: Optional arguments.
        #
        # ==== Options
        # :delta<Boolean>::
        #   Delta index. Delta indexes will be searched last when multiple indexes are defined for a
        #   resource. Default is false.
        def initialize(model, name, options = {})
          assert_kind_of 'model',   model,   Model
          assert_kind_of 'name',    name,    Symbol, String
          assert_kind_of 'options', options, Hash

          @model = model
          @name  = name.to_sym
          @delta = options.fetch(:delta, false)
        end

        # Is the index a delta index.
        def delta?
          !!@delta
        end
      end # Index
    end # Sphinx
  end # Adapters
end # DataMapper
