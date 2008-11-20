require 'rubygems'
require 'dm-is-searchable'
require 'zlib'

class Item
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String, :nullable => false, :length => 50
  property :likes,      Text
  property :updated_on, DateTime

  is :searchable
end # Item
