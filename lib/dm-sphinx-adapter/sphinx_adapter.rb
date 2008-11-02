require 'benchmark'

module DataMapper
  module Adapters
    class SphinxAdapter < AbstractAdapter

      # Keep in mind dm-is-searchable fires .create on :save.
      def create(resources)
        indexes = resources.map{|r| delta_indexes(r.model)}.flatten.uniq
        rotate  = indexes.map{|d| d.name}.join(' ')
        return true if rotate.empty?

        time = Benchmark.realtime do
          # TODO: system indexer #{rotate} once I know where to point --config and which directory to
          # chdir to in order to make the paths in .conf happy.
        end
        DataMapper.logger.debug(%q{Sphinx (%.3f): rotate '%s' index(es)} % [time, rotate])
        resources.size
      end

      def delete(query)
        DataMapper.logger.debug(%q{Sphinx (%.3f): TODO: delete})
        # Thinking Sphinx uses a deleted attribute in sphinx.conf but that's a requirement I don't really want to
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
        def indexes(model)
          if model.respond_to?(:sphinx_indexes)
            model.sphinx_indexes(repository(self.name).name)
          else
            [SphinxIndex.new(model, Extlib::Inflection.tableize(model.name))]
          end
        end

        def delta_indexes(model)
          indexes(model).find_all{|i| i.delta?}
        end

        def read(query)
          # TODO: .load ourselves from :default when not DataMapper::Is::Searchable?
          from   = indexes(query.model).map{|index| index.name}.join(', ')
          search = search_query(query)
          client = client_from_dm_query(query)
          res    = client.query(search, from)
          raise res[:error] unless res[:error].nil?

          DataMapper.logger.info(
            %q{Sphinx (%.3f): search '%s' in '%s' found %d documents} % [res[:time], search, from, res[:total]]
          )
          res[:matches].map{|doc| doc[:doc]}
        end

        def client_from_dm_query(query)
          # TODO: Self hosting? Move this code into the Client lib that'll take care of searchd and indexer.
          # Use the @url.path from initialize to find the location of your sphinx .conf
          client            = Riddle::Client.new(@uri.host, @uri.port)
          client.match_mode = :extended # TODO: Modes!
          client.limit      = query.limit ? query.limit.to_i : 0
          client.offset     = query.offset ? query.offset.to_i : 0

          # TODO: How do you tell the difference between the default query order and someone explicitly asking for
          # sorting by the primary key?
          # client.sort_by = query.order.map{|o| [o.property.field, o.direction].join(' ')}.join(', ') \
          #  unless query.order.empty?

          client
        end

        def search_query(query)
          match  = []

          if query.conditions.empty?
            # Full scan mode.
            # http://www.sphinxsearch.com/doc.html#searching
            # http://www.sphinxsearch.com/doc.html#conf-docinfo
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

        # Ripped pretty much straight from the 0.9.7 data objects adapter.
        # I don't understand why this isn't in the abstract adapter.
        def normalize_uri(uri_or_options)
          if uri_or_options.kind_of?(String) || uri_or_options.kind_of?(Addressable::URI)
            uri_or_options = DataObjects::URI.parse(uri_or_options)
          end

          if uri_or_options.kind_of?(DataObjects::URI)
            return uri_or_options
          end

          adapter  = uri_or_options.delete(:adapter).to_s
          user     = uri_or_options.delete(:username)
          password = uri_or_options.delete(:password)
          host     = uri_or_options.delete(:host)
          port     = uri_or_options.delete(:port)
          database = uri_or_options.delete(:database)
          query    = uri_or_options.to_a.map { |pair| pair * '=' } * '&'
          query    = nil if query == ''

          DataObjects::URI.parse(Addressable::URI.new(adapter, user, password, host, port, database, query, nil))
        end
    end # SphinxAdapter
  end # Adapters
end # DataMapper

