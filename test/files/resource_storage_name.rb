class StorageName
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :likes,      Text, :lazy => false
  property :updated_on, DateTime

  def self.default_storage_name
    'item'
  end
end # StorageName
