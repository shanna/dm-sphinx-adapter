require 'rubygems'
require 'dm-is-searchable'
require 'zlib'

class Item
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id, Integer, :key => true, :writer => :private
  property :name, String, :nullable => false, :length => 50
  property :likes, Text
  property :updated_on, DateTime

  is :searchable
  repository(:search) do
    index :items
    index :items_delta, :delta => true

    # TODO: More attributes.
    attribute :updated, DateTime
  end

  # I'm using my own (unreleased) Digest::CRC32 DataMapper::Type normally.
  after :name, :set_id

  protected
    def set_id
      attribute_set(:id, Zlib.crc32(name))
    end
end
