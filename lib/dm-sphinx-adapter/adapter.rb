module DataMapper
  module Sphinx
    class Adapter < DataMapper::Adapters::AbstractAdapter
      #--
      # TODO: Error.
      # TODO: Wait for live indexing or someone to write a gateway/manager that will buffer and fake it?
      # Steal Solr's restful api for bonus points and create dm-search-adapter for Sphinx, Solr etc.
      def create(resources) #:nodoc:
        0
      end

      #--
      # TODO: Allow updating of attributes.
      def update(attributes, collection) #:nodoc:
        0
      end

      #--
      # TODO: Error.
      def delete(query) #:nodoc:
        0
      end

      def read(query)
        with_connection do |client|
          # TODO: Yuck. I can't really ditch the Search struct withou having naming collisions in Query but it's causing
          # some ugly and non obvious method chains here.
          client.match_mode = query.search.match.mode
          client.filters    = query.search.filter.statement
          client.limit      = query.limit.to_i  if query.limit
          client.offset     = query.offset.to_i if query.offset
          # TODO: Ordering (this is where I would get classes with the Query order methods).

          client.query(query.search.match.statement, query.model.storage_name, '').map do |record|
            query.fields.zip(record[:attributes]).to_hash
          end
        end
      end

      # ==== Returns
      # DataMapper::Sphinx::Query
      def new_query *args
        Query.new(*args)
      end

      protected
        def with_connection
          begin
            connection = Connection.new(@options[:host], @options[:port])
            yield connection
          ensure
            connection.dispose unless connection.nil?
          end
        end
    end # Adapter
  end # Sphinx

  Adapters::SphinxAdapter = DataMapper::Sphinx::Adapter
  Adapters.const_added(:SphinxAdapter)
end # DataMapper

