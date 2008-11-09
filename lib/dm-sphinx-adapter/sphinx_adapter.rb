require 'benchmark'

module DataMapper
  module Adapters

    # == Synopsis
    # DataMapper uses URIs or a connection has to connect to your data-stores. In this case the sphinx search daemon
    # <tt>searchd</tt>.
    #
    # On its own this adapter will only return an array of document IDs when queried. The dm-more source (not the gem)
    # however provides dm-is-searchable, a common interface to search one adapter and load documents from another. My
    # suggestion is to use this adapter in tandem with dm-is-searchable.
    #
    # The dm-is-searchable plugin is part of dm-more though unfortunately isn't built and bundled with dm-more gem.
    # You'll need to checkout the dm-more source with Git from git://github.com/sam/dm-more.git and build/install the
    # gem yourself.
    #
    #   git clone git://github.com/sam/dm-more.git
    #   cd dm-more/dm-is-searchable
    #   sudo rake install_gem
    #
    # Like all DataMapper adapters you can connect with a Hash or URI.
    #
    # A URI:
    #   DataMapper.setup(:search, 'sphinx://localhost')
    #
    # The breakdown is:
    #   "#{adapter}://#{host}:#{port}/#{config}"
    #   - adapter Must be :sphinx
    #   - host    Hostname (default: localhost)
    #   - port    Optional port number (default: 3312)
    #   - config  Optional path to sphinx config file.
    #
    # Alternatively supply a Hash:
    #   DataMapper.setup(:search, {
    #     :adapter  => 'sphinx',       # required
    #     :config   => './sphinx.conf' # optional. Strongly recommended though.
    #     :host     => 'localhost',    # optional. Default: localhost
    #     :port     => 3312            # optional. Default: 3312
    #     :managed  => true            # optional. Self managed searchd server using daemon_controller.
    #   })
    class SphinxAdapter < AbstractAdapter
      def initialize(name, uri_or_options)
        super

        @managed = !!(uri_or_options.kind_of?(Hash) && uri_or_options[:managed])
        @client  = @managed ? SphinxManagedClient.new(uri_or_options) : SphinxClient.new(uri_or_options)
      end

      def create(resources)
        # Keep in mind dm-is-searchable fires .create on :save.
        indexes = resources.map{|r| delta_indexes(r.model)}.flatten.uniq
        rotate  = indexes.map{|d| d.name}.join(' ')
        return true if rotate.empty?

        time = Benchmark.realtime{ @client.index(rotate) }
        DataMapper.logger.debug(%q{Sphinx (%.3f): indexed '%s' index(es)} % [time, rotate])
        resources.size
      end

      def delete(query)
        DataMapper.logger.debug(%q{Sphinx (%.3f): TODO: delete})
        # TODO: Thinking Sphinx uses a deleted attribute in sphinx.conf but that's a requirement I don't really want to
        # impose on the author. I'll go check what ultrasphinx does.
        true
      end

      def read_many(query)
        read(query)
      end

      def read_one(query)
        read(query).first
      end

      protected
        ##
        # List sphinx indexes to search.
        # If no indexes are explicitly declared using DataMapper::SphinxResource then the tableized model name is used.
        #
        # @see DataMapper::SphinxResource#sphinx_indexes
        def indexes(model)
          indexes = model.sphinx_indexes(repository(self.name).name) if model.respond_to?(:sphinx_indexes)
          if indexes.nil? or indexes.empty?
            # TODO: Is it resource_naming_convention.call(model.name) ?
            indexes = [SphinxIndex.new(model, Extlib::Inflection.tableize(model.name))]
          end
          indexes
        end

        ##
        # List sphinx delta indexes to search.
        #
        # @see DataMapper::SphinxResource#sphinx_indexes
        def delta_indexes(model)
          indexes(model).find_all{|i| i.delta?}
        end

        ##
        # Query sphinx for a list of document IDs.
        #
        # @param [DataMapper::Query]
        def read(query)
          # TODO: .load ourselves from :default when not DataMapper::Is::Searchable?
          from   = indexes(query.model).map{|index| index.name}.join(', ')
          search = search_query(query)
          res    = @client.search(search, from,
            :match_mode => :extended, # TODO: Modes!
            :limit      => (query.limit  ? query.limit.to_i : 0),
            :offset     => (query.offset ? query.offset.to_i : 0)
          )
          raise res[:error] unless res[:error].nil?

          DataMapper.logger.info(
            %q{Sphinx (%.3f): search '%s' in '%s' found %d documents} % [res[:time], search, from, res[:total]]
          )
          res[:matches].map{|doc| doc[:doc]}
        end

        ##
        # Generate a Sphinx search query string.
        #
        # If the query has no conditions an '' empty string will be generated possibly triggering Sphinx's full scan
        # mode.
        #
        # @see    http://www.sphinxsearch.com/doc.html#searching
        # @see    http://www.sphinxsearch.com/doc.html#conf-docinfo
        # @param  [DataMapper::Query]
        # @return [String]
        def search_query(query)
          match  = []

          if query.conditions.empty?
            match << ''
          else
            # TODO: This needs to be altered by match mode since not everything is supported in different match modes.
            query.conditions.each do |operator, property, value|
              # TODO: Why does my gem riddle differ from the vendor riddle that comes with ts?
              # escaped_value = Riddle.escape(value)
              escaped_value = value.gsub(/[\(\)\|\-!@~"&\/]/){|char| "\\#{char}"}
              match << case operator
                when :eql, :like then "@#{property.field} #{escaped_value}"
                when :not        then "@#{property.field} -#{escaped_value}"
                when :lt, :gt, :lte, :gte
                  DataMapper.logger.warn('Sphinx query lt, gt, lte, gte are treated as .eql matches')
                  "@#{name} #{escaped_value}"
                when :raw
                  "#{property}"
              end
            end
          end
          match.join(' ')
        end
    end # SphinxAdapter
  end # Adapters
end # DataMapper

