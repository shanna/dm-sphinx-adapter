class StorageName
  include DataMapper::Resource
  property :id,         Serial
  property :t_string,   String
  property :t_text,     Text, :lazy => false
  property :t_decimal,  BigDecimal
  property :t_float,    Float
  property :t_integer,  Integer
  property :t_datetime, DateTime

  def self.default_storage_name
    'item'
  end
end # StorageName
