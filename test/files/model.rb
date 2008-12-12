class Item
  include DataMapper::SphinxResource
  property :id,         Serial
  property :t_string,   String
  property :t_text,     Text, :lazy => false
  property :t_decimal,  BigDecimal
  property :t_float,    Float
  property :t_integer,  Integer
  property :t_datetime, DateTime

  repository(:search) do
    properties(:search).clear
    property :id,         Serial
    property :t_string,   String

    attribute :t_text,     Text, :lazy => false
    attribute :t_decimal,  BigDecimal
    attribute :t_float,    Float
    attribute :t_integer,  Integer
    attribute :t_datetime, DateTime
  end
end # Item

