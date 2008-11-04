module DataMapper
  class SphinxAttribute < Property

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

  end # SphinxAttribute
end # DataMapper
