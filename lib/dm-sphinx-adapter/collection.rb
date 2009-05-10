module DataMapper
  module Adapters
    module Sphinx
      class Collection < Array
        attr_accessor :error, :time, :total, :words

        def initialize(result)
          # TODO: One liner that works in Ruby 1.x now #indexes is #keys?
          @error   = result[:error]
          @time    = result[:time]
          @total   = result[:total]
          @words   = result[:words]
          super result[:matches].map{|doc| doc[:id] = doc[:doc]; doc}
        end

      end
    end # Sphinx
  end # Adapters
end # DataMapper
