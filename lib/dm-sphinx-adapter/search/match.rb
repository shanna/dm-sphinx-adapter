require 'dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      # TODO: Move the modes factory from Sphinx::Query to here.
      class Match < Statement

        # Symbol for each mode.
        def mode
          raise NotImplementedError
        end
      end # Mode
    end # Search
  end # Sphinx
end # DataMapper
