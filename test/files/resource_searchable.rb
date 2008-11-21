require 'rubygems'
require 'dm-is-searchable'

class Searchable
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :likes,      Text, :lazy => false
  property :updated_on, DateTime

  is :searchable

  def self.default_storage_name
    'item'
  end
end # Searchable
