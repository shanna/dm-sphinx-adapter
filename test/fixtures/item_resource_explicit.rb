require 'rubygems'
require 'dm-is-searchable'
require 'zlib'

class ItemResourceExplicit
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id,         Serial
  property :name,       String, :nullable => false, :length => 50
  property :likes,      Text
  property :updated_on, DateTime

  is :searchable
  repository(:search) do
    properties(:search).clear
    index     :items
    index     :items_delta, :delta => true
    property  :name,    String
    attribute :updated, DateTime
  end

  def self.default_storage_name
    'item'
  end
end # ItemResourceExplicit
