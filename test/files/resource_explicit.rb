require 'rubygems'
require 'dm-is-searchable'

class Explicit
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id,         Serial
  property :name,       String
  property :likes,      Text, :lazy => false
  property :updated_on, DateTime

  is :searchable
  repository(:search) do
    properties(:search).clear
    index     :items
    index     :items_delta, :delta => true
    property  :name,    String
    attribute :updated_on, DateTime
  end

  def self.default_storage_name
    'item'
  end
end # Explicit
