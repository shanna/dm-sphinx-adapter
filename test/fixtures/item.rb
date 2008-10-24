require 'rubygems'

require 'dm-is-searchable'
require 'zlib'

class Item
  include DataMapper::Resource

  property :id, Integer, :key => true, :writer => :private
  property :name, String, :nullable => false, :length => 50
  property :likes, Text
  property :updated_on, DateTime

  is :searchable

  # I'm using my own (unreleased) Digest::CRC32 DataMapper::Type normally.
  after :name, :set_id

  protected
    def set_id
      attribute_set(:id, Zlib.crc32(name))
    end
end
