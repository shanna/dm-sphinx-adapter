require 'rubygems'
require 'dm-is-searchable'
require 'zlib'

class ItemResourceExplicit
  include DataMapper::Resource
  include DataMapper::SphinxResource

  property :id,         Integer, :key => true, :writer => :private
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

  def default_storage_name
    'items'
  end

  # I'm using my own (unreleased) Digest::CRC32 DataMapper::Type normally.
  after :name, :set_id

  protected
    def set_id
      attribute_set(:id, Zlib.crc32(name))
    end
end # ItemResourceExplicit
