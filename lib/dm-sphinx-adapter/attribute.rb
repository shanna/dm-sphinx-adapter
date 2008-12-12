require 'date'
require 'time'

module DataMapper
  module Adapters
    module Sphinx

      # Sphinx attribute definition.
      #
      # You must declare attributes as such if you want to use them for sorting or conditions.
      #
      # ==== Notes
      # The following primatives will be used as sql_attr_* types. Some liberty has been taken to accommodate for as
      # many DM primitives as possible.
      #
      # TrueClass::                 sql_attr_bool
      # String::                    sql_attr_str2ordinal
      # DataMapper::Types::Text::   sql_attr_str2ordinal
      # Float::                     sql_attr_float
      # Integer::                   sql_attr_uint
      # BigDecimal::                sql_attr_float
      # DateTime::                  sql_attr_timestamp
      # Date::                      sql_attr_timestamp
      # Time::                      sql_attr_timestamp
      # DataMapper::Types::Serial:: sql_attr_uint
      class Attribute < Property

        # DataMapper types supported as Sphinx attributes.
        TYPES = [
          TrueClass,                # sql_attr_bool
          String,                   # sql_attr_str2ordinal
          DataMapper::Types::Text,  # sql_attr_str2ordinal
          Float,                    # sql_attr_float
          Integer,                  # sql_attr_uint
          BigDecimal,               # sql_attr_float
          DateTime,                 # sql_attr_timestamp
          Date,                     # sql_attr_timestamp
          Time,                     # sql_attr_timestamp
          # Object,
          # Class,
          # DataMapper::Types::Discriminator,
          DataMapper::Types::Serial # sql_attr_uint
        ]

        # Create a riddle client filter from a value.
        #
        # ==== Parameters
        # value<Object>::
        #   The filter value to typecast and include/exclude.
        #
        # inclusive<Boolean>::
        #   Include or exclude results matching the filter value. Default: inclusive (true).
        #
        # ==== Returns
        # Riddle::Client::Filter::
        def filter(value, inclusive = true)
          # Riddle uses exclusive = false as the default which doesn't read well IMO. Nobody says "Yes I don't want
          # these values" you say "No I don't want these values".
          value = typecast(value)
          value = [value] unless value.quacks_like?([Array, Range])
          Riddle::Client::Filter.new(field, value, !inclusive)
        end

        # Typecasts the value into a sphinx primitive. Supports ranges or arrays of values.
        #
        # ==== Notes
        # Some loss of precision may occur when casting BigDecimal to Float.
        def typecast(value)
          if    value.kind_of?(Range)   then Range.new(typecast(value.first), typecast(value.last))
          elsif value.kind_of?(Array)   then value.map{|v| typecast(v)}
          elsif primitive == BigDecimal then super(value).to_f
          elsif primitive == DateTime   then Time.parse(super(value).to_s).to_i
          elsif primitive == Date       then Time.parse(super(value).to_s).to_i
          elsif primitive == Time       then super(value).to_i
          else
            super(value) # Good luck
          end
        end

      end # Attribute
    end # Sphinx
  end # Adapters
end # DataMapper
