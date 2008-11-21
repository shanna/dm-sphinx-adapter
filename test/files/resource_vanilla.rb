class Vanilla
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :likes,      Text, :lazy => false
  property :updated_on, DateTime
end # Vanilla
