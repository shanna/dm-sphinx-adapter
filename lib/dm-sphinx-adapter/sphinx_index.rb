module DataMapper
  class SphinxIndex
    include Assertions

    attr_reader :model, :name, :options

    def initialize(model, name, options = {})
      assert_kind_of 'model',   model,   Model
      assert_kind_of 'name',    name,    Symbol, String
      assert_kind_of 'options', options, Hash

      @model = model
      @name  = name.to_sym
      @delta = options.fetch(:delta, nil)
    end

    def delta?
      !!@delta
    end
  end # SphinxIndex
end # DataMapper
