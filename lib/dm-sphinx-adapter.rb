require 'rubygems'

gem 'dm-core', '~> 0.9.6'
require 'dm-core'

gem 'riddle', '~> 0.9'
require 'riddle'

module DataMapper
  module Adapters
    class SphinxAdapter < AbstractAdapter
      def create(resources)
        # TODO: Delta indexing.
        true
      end

      def delete(query)
        # TODO: Delta indexing.
        true
      end

      def read_many(query)
        read(query)
      end

      def read_one(query)
        read(query).first
      end

      protected
        def read(query)
          # TODO: .load ourselves from :default when not DataMapper::Is::Searchable?
          search = query_from_dm_query(query)
          client = client_from_dm_query(query)
          res    = client.query(*search)

          DataMapper.logger.info("Sphinx #{search.last} '#{search.first}' #{res[:total]} found (#{res[:time]})")
          res[:matches].map{|doc| doc[:doc]}
        end

        def query_from_dm_query(query)
          index = Extlib::Inflection.tableize(query.model.name)
          match = []

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
          [match.join(' '), index]
        end

        def client_from_dm_query(query)
          client            = Riddle::Client.new(@uri.host, @uri.port)
          client.match_mode = :extended
          client.limit      = query.limit  ? query.limit.to_i : 0
          client.offset     = query.offset ? query.offset.to_i : 0

          # TODO: How do you tell the difference between the default query order and someone explicitly asking for
          # sorting by the primary key?
          # client.sort_by = query.order.map{|o| [o.property.field, o.direction].join(' ')}.join(', ') \
          #  unless query.order.empty?

          client
        end

        # Ripped pretty much straight from the 0.9.6 gem data objects adapter.
        # I don't understand why this isn't in the abstract adapter.
        def normalize_uri(uri_or_options)
          if uri_or_options.kind_of?(String)
            uri_or_options = Addressable::URI.parse(uri_or_options)
          end

          if uri_or_options.kind_of?(Addressable::URI)
            return uri_or_options.normalize
          end

          adapter  = uri_or_options.delete(:adapter).to_s
          user     = uri_or_options.delete(:username)
          password = uri_or_options.delete(:password)
          host     = uri_or_options.delete(:host)
          port     = uri_or_options.delete(:port)
          database = uri_or_options.delete(:database)
          query    = uri_or_options.to_a.map{|pair| pair * '='} * '&'
          query    = nil if query == ''

          Addressable::URI.new(adapter, user, password, host, port, database, query, nil)
        end

    end # SphinxAdapter
  end # Adapters
end # DataMapper

