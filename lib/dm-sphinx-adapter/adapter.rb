module DataMapper
  module Adapters
    module Sphinx
      # == Synopsis
      #
      # DataMapper uses URIs or a connection has to connect to your data-stores. In this case the sphinx search daemon
      # <tt>searchd</tt>.
      #
      # On its own this adapter will only return an array of document hashes when queried. The DataMapper library dm-more
      # however provides dm-is-searchable, a common interface to search one adapter and load documents from another. My
      # preference is to use this adapter in tandem with dm-is-searchable.
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
      #
      # Alternatively supply a Hash:
      #   DataMapper.setup(:search, {
      #     :adapter  => 'sphinx',       # required
      #     :host     => 'localhost',    # optional. Default: localhost
      #     :port     => 3312            # optional. Default: 3312
      #   })
      class Adapter < AbstractAdapter

        # ==== See
        # * DataMapper::Adapters::AbstractAdapter
        #
        # ==== Parameters
        # uri_or_options<URI, DataObject::URI, Addressable::URI, String, Hash, Pathname>::
        #   DataMapper uri or options hash.
        def initialize(name, uri_or_options)
          super # Set up defaults.
          @options = normalize_options(uri_or_options)
        end

        def create(resources) #:nodoc:
          0
        end

        def delete(query) #:nodoc:
          0
        end

        # Query your Sphinx repository and return all matching documents.
        #
        # ==== Notes
        #
        # These methods are public but normally called indirectly through DataMapper::Resource#get,
        # DataMapper::Resource#first or DataMapper::Resource#all.
        #
        # The document hashes returned are those from Riddle::Client.
        #
        # ==== Parameters
        # query<DataMapper::Query>:: The query object.
        #
        # ==== Returns
        # Array<Hash>:: An array of document hashes. <tt>[{:id => 1, ...}, {:id => 2, ...}]</tt>
        # Array<>::     An empty array if no documents match.
        def read_many(query)
          read(query)
        end

        # Query your Sphinx repository and return the first document matched.
        #
        # ==== Notes
        #
        # These methods are public but normally called indirectly through DataMapper::Resource#get,
        # DataMapper::Resource#first or DataMapper::Resource#all.
        #
        # ==== Parameters
        # query<DataMapper::Query>:: The query object.
        #
        # ==== Returns
        # Hash:: An document hash of the first document matched. <tt>{:id => 1, ...}</tt>
        # Nil::  If no documents match.
        def read_one(query)
          read(query).first
        end

        protected
          # List sphinx indexes to search.
          #
          # If no indexes are explicitly declared using DataMapper::Adapters::Sphinx::Resource then the default storage
          # name is used.
          #
          # ==== See
          # * DataMapper::Adapters::Sphinx::Resource::ClassMethods#sphinx_indexes
          #
          # ==== Parameters
          # model<DataMapper::Model>:: The DataMapper::Model.
          #
          # ==== Returns
          # Array<DataMapper::Adapters::Sphinx::Index>:: Index objects from the model.
          def indexes(model)
            indexes = model.sphinx_indexes(repository(self.name).name) if model.respond_to?(:sphinx_indexes)
            if indexes.nil? or indexes.empty?
              indexes = [Index.new(model, model.storage_name)]
            end
            indexes
          end

          # Query sphinx for a list of document IDs.
          #
          # ==== Parameters
          # query<DataMapper::Query>:: The query object.
          #
          # ==== Returns
          # Array<Hash>:: An array of document hashes. <tt>[{:id => 1, ...}, {:id => 2, ...}]</tt>
          # Array<>::     An empty array if no documents match.
          def read(query)
            from   = indexes(query.model).map{|index| index.name}.join(', ')
            search = Sphinx::Query.new(query).to_s
            client = Riddle::Client.new(@options[:host], @options[:port])

            # You can set some options that aren't set by the adapter.
            @options.except(:host, :port, :match_mode, :limit, :offset, :sort_mode, :sort_by).each do |k, v|
              client.method("#{k}=".to_sym).call(v) if client.respond_to?("#{k}=".to_sym)
            end

            client.match_mode = :extended
            client.filters    = search_filters(query) # By attribute.
            client.limit      = query.limit.to_i  if query.limit
            client.offset     = query.offset.to_i if query.offset

            if order = search_order(query)
              client.sort_mode = :extended
              client.sort_by   = order
            end

            result = client.query(search, from)
            raise result[:error] unless result[:error].nil?

            DataMapper.logger.info(
              %q{Sphinx (%.3f): search '%s' in '%s' found %d documents} % [result[:time], search, from, result[:total]]
            )
            result[:matches].map{|doc| doc[:id] = doc[:doc]; doc}
          end


          # Riddle search filters for attributes.
          def search_filters(query) #:nodoc:
            filters = []
            query.conditions.each do |operator, attribute, value|
              next unless attribute.kind_of? Sphinx::Attribute
              filters << case operator
                when :eql, :like then attribute.filter(value)
                when :not        then attribute.filter(value, false)
                else raise NotImplementedError.new("Sphinx: Query attributes do not support the #{operator} operator")
              end
            end
            filters
          end

          # TODO: How do you tell the difference between the default query order and someone explicitly asking for
          # sorting by the primary key? I don't think you can at the moment.
          def search_order(query) #:nodoc:
            by = []
            query.order.each do |order|
              next unless order.property.kind_of? Sphinx::Attribute
              by << [order.property.field, order.direction].join(' ')
            end
            by.empty? ? nil : by.join(', ')
          end

          # Coerce +uri_or_options+ into a +Hash+ of options.
          #
          # ==== Parameters
          # uri_or_options<URI, DataObject::URI, Addressable::URI, String, Hash, Pathname>::
          #   DataMapper uri or options hash.
          #
          # ==== Returns
          # Hash
          def normalize_options(uri_or_options)
            case uri_or_options
              when String, Addressable::URI then DataObjects::URI.parse(uri_or_options).attributes
              when DataObjects::URI         then uri_or_options.attributes
              when Pathname                 then {:path => uri_or_options}
              else
                uri_or_options[:path] ||= uri_or_options.delete(:config) || uri_or_options.delete(:database)
                uri_or_options
            end
          end

      end # Adapter
    end # Sphinx

    # Keep magic in DataMapper#setup happy.
    SphinxAdapter = Sphinx::Adapter
  end # Adapters
end # DataMapper

