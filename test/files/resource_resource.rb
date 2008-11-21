require 'rubygems'
require 'dm-is-searchable'

class Resource
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id,         Serial
  property :name,       String
  property :likes,      Text, :lazy => false
  property :updated_on, DateTime

  is :searchable

  def self.default_storage_name
    'item'
  end
end # Resource

