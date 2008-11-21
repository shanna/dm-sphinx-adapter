module DataMapper
  module Adapters
    module Sphinx

      ##
      # Define a Sphinx attribute.
      #
      # Supports only a subset of DataMapper::Property types that can be used as Sphinx attributes.
      #
      # * TrueClass                 # sql_attr_bool
      # * String                    # sql_attr_str2ordinal
      # * Float,                    # sql_attr_float
      # * Integer,                  # sql_attr_uint
      # * DateTime,                 # sql_attr_timestamp
      # * Date,                     # sql_attr_timestamp
      # * DataMapper::Types::Serial # sql_attr_uint
      class Attribute < Property

        # DataMapper types supported as Sphinx attributes.
        TYPES = [
          TrueClass,                # sql_attr_bool
          String,                   # sql_attr_str2ordinal
          # DataMapper::Types::Text,
          Float,                    # sql_attr_float
          Integer,                  # sql_attr_uint
          # BigDecimal,             # sql_attr_float?
          DateTime,                 # sql_attr_timestamp
          Date,                     # sql_attr_timestamp
          Time,                     # sql_attr_timestamp
          # Object,
          # Class,
          # DataMapper::Types::Discriminator,
          DataMapper::Types::Serial # sql_attr_uint
        ]

      end # Attribute
    end # Sphinx
  end # Adapters
end # DataMapper
