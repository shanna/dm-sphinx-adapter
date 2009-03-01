require 'builder'

module DataMapper
  module Adapters
    module Sphinx

      # Sphinx xmlpipe2.
      #
      # Full text search data from any DM adapter without having to implement new Sphinx data sources drivers.
      #
      # ==== See
      # * http://www.sphinxsearch.com/docs/current.html#xmlpipe2
      #
      #--
      # TODO:
      # * Synopsis.
      module XmlPipe2
        def self.included(model)
          model.extend ClassMethods if defined?(ClassMethods)
        end

        module ClassMethods

          # Write a Sphinx xmlpipe2 XML stream to $stdout.
          #
          # ==== Parameters
          # source<String>::      The name of the repository to stream from.
          # destination<String>:: The name of the repository to stream to (contains your sphinx definition).
          # query<Hash>::         The conditions with which to find the records to stream.
          #--
          # TODO:
          # * in_memory_adapter doesn't call the super constructor so there is no field_naming_convention set in
          # DataMapper 0.9.10. Submit a patch or live with rescue and field.name clause?
          # * Keys that aren't called .id?
          # * Composite keys?
          # * Method for schema and documents.
          # * Less poking round in the internals of the :default adapter if I can?
          # * Destination should always be a dm-sphinx-adapter adapter.
          # * Optional schema since it overrides any schema you might define in the sphinx configuration.
          # * Schema default values from DM property default values.
          def xmlpipe2(source, destination = :default, query = {})
            builder = Builder::XmlMarkup.new(:target => $stdout)
            builder.instruct!
            builder.sphinx(:docset, :'xmlns:sphinx' => 'sphinx') do

              builder.sphinx(:schema) do
                sphinx_fields(destination).each do |field|
                  builder.sphinx(:field, :name => (field.field(destination) rescue field.name))
                end
                sphinx_attributes(destination).each do |attr|
                  builder.sphinx(:attr, {
                    :name => (attr.field(destination) rescue attr.name),
                    :type => xmlpipe2_type(attr.primitive)
                  })
                end
              end

              all(query.merge(:repository => repository(source))).map do |resource|
                builder.sphinx(:document, :id => resource.id) do |document|
                  properties(destination).each do |property|
                    # TODO: Pretty sure this isn't the correct way to get and typecast.
                    builder.tag!((property.field(destination) rescue property.name)) do |field|
                      field.cdata!(property.typecast(property.get(resource)))
                    end
                  end
                end
              end
            end
          end

          private
            def xmlpipe2_type(primitive) #:nodoc:
              {
                Integer                 => 'int',
                Float                   => 'float',
                BigDecimal              => 'float',
                DateTime                => 'timestamp',
                Date                    => 'timestamp',
                Time                    => 'timestamp',
                TrueClass               => 'bool',
                String                  => 'str2ordinal',
                DataMapper::Types::Text => 'str2ordinal'
              }[primitive]
            end

        end # ClassMethods
      end # XmlPipe2

      # Include XmlPipe2 in all DM::A::SphinxResource models when you require this file.
      Resource.append_inclusions XmlPipe2
    end # Sphinx
  end # Adapters
end # DataMapper

