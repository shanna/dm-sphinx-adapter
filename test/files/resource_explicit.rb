require 'rubygems'
require 'dm-is-searchable'

class Explicit
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id,         Serial
  property :t_string,   String
  property :t_text,     Text, :lazy => false
  property :t_decimal,  BigDecimal
  property :t_float,    Float
  property :t_integer,  Integer
  property :t_datetime, DateTime

  is :searchable
  repository(:search) do
    properties(:search).clear
    index     :items
    index     :items_delta, :delta => true

    property :id,         Serial
    property :t_string,   String

    attribute :t_text,     Text, :lazy => false
    attribute :t_decimal,  BigDecimal
    attribute :t_float,    Float
    attribute :t_integer,  Integer
    attribute :t_datetime, DateTime
  end

  def self.default_storage_name
    'item'
  end
end # Explicit
