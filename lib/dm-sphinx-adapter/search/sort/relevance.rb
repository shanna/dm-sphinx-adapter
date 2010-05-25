require 'dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      module Sort
        class Relevance < Statement
          def mode
            :relevance
          end

          def statement
            ''
          end
        end # Relevance
      end # Sort
    end # Search
  end # Sphinx
end # DataMapper
