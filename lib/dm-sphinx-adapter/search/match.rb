require 'dm-sphinx-adapter/search/statement'

module DataMapper
  module Sphinx
    class Search
      # TODO: Move the modes factory from Sphinx::Query to here.
      class Match < Statement
        include Query::Conditions

        # Symbol for each mode.
        def mode
          raise NotImplementedError
        end

        def quote value
          value.to_s.gsub(/[\(\)\|\-!@~"&\/]/){|char| "\\#{char}"}
        end
      end # Mode
    end # Search
  end # Sphinx
end # DataMapper
