require 'rubygems'
require 'dm-is-searchable'
require 'zlib'

class ItemResourceOnly
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id,         Serial
  property :name,       String, :nullable => false, :length => 50
  property :likes,      Text
  property :updated_on, DateTime

  is :searchable

  def self.default_storage_name
    'item'
  end
end # ItemResourceOnly

