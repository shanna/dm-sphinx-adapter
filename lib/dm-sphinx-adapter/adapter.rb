require 'benchmark'

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
      #   - config  Optional but recommended path to sphinx config file.
      #
      # Alternatively supply a Hash:
      #   DataMapper.setup(:search, {
      #     :adapter  => 'sphinx',       # required
      #     :config   => './sphinx.conf' # optional. Recommended though.
      #     :host     => 'localhost',    # optional. Default: localhost
      #     :port     => 3312            # optional. Default: 3312
      #     :managed  => true            # optional. Self managed searchd server using daemon_controller.
      #   })
      class Adapter < AbstractAdapter

        # ==== See
        # * DataMapper::Adapters::Sphinx::Config
        # * DataMapper::Adapters::Sphinx::Client
        #
        # ==== Parameters
        # uri_or_options<URI, DataObject::URI, Addressable::URI, String, Hash, Pathname>::
        #   DataMapper uri or options hash.
        def initialize(name, uri_or_options)
          super

          managed = !!(uri_or_options.kind_of?(Hash) && uri_or_options[:managed])
          @client  = managed ? ManagedClient.new(uri_or_options) : Client.new(uri_or_options)
        end

        # Interaction with searchd and indexer.
        #
        # ==== See
        # * DataMapper::Adapters::Sphinx::Client
        # * DataMapper::Adapters::Sphinx::ManagedClient
        #
        # ==== Returns
        # DataMapper::Adapters::Sphinx::Client:: The client.
        attr_reader :client

        def create(resources) #:nodoc:
          true
        end

        def delete(query) #:nodoc:
          true
        end

        # Query your Sphinx repository and return all matching documents.
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
        # Array<Hash>:: An array of document hashes. <tt>[{:id => 1}, {:id => 2}]</tt>
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
        # Hash:: An document hash of the first document matched. <tt>{:id => 1}</tt>
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

          # List sphinx delta indexes to search.
          #
          # ==== See
          # * DataMapper::Adapters::Sphinx::Resource::ClassMethods#sphinx_indexes
          #
          # ==== Parameters
          # model<DataMapper::Model>:: The DataMapper::Model.
          #
          # ==== Returns
          # Array<DataMapper::Adapters::Sphinx::Index>:: Index objects from the model.
          def delta_indexes(model)
            indexes(model).find_all{|i| i.delta?}
          end

          # Query sphinx for a list of document IDs.
          #
          # ==== Parameters
          # query<DataMapper::Query>:: The query object.
          #
          # ==== Returns
          # Array<Hash>:: An array of document hashes. <tt>[{:id => 1}, {:id => 2}]</tt>
          # Array<>::     An empty array if no documents match.
          def read(query)
            from    = indexes(query.model).map{|index| index.name}.join(', ')
            search  = Sphinx::Query.new(query).to_s
            options = {
              :match_mode => :extended,
              :filters    => search_filters(query) # By attribute.
            }
            options[:limit]  = query.limit.to_i  if query.limit
            options[:offset] = query.offset.to_i if query.offset

            if order = search_order(query)
              options.update(
                :sort_mode => :extended,
                :sort_by   => order
              )
            end

            indexes = indexes.join(' ') if indexes.kind_of?(Array)

            client = Riddle::Client.new(@uri.host, @uri.port)
            options.each{|k, v| client.method("#{k}=".to_sym).call(v) if client.respond_to?("#{k}=".to_sym)}
            res = client.query(query, indexes.to_s)
            raise res[:error] unless res[:error].nil?

            DataMapper.logger.info(
              %q{Sphinx (%.3f): search '%s' in '%s' found %d documents} % [res[:time], search, from, res[:total]]
            )
            res[:matches].map{|doc| {:id => doc[:doc]}}
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
      end # Adapter
    end # Sphinx

    # Keep magic in DataMapper#setup happy.
    SphinxAdapter = Sphinx::Adapter
  end # Adapters
end # DataMapper

