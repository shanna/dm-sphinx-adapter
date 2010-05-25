require 'dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      module Sort
        class Rank < Statement
          def mode
            :rank
          end

          def statement
            ''
          end
        end # Rank
      end # Sort
    end # Search
  end # Sphinx
end # DataMapper
