= DataMapper Sphinx Adapter

A Sphinx DataMapper adapter.

== Synopsis

=== DataMapper

  require 'rubygems'
  require 'dm-sphinx-adapter'

  DataMapper.setup(:default, 'sqlite3::memory:')
  DataMapper.setup(:search, 'sphinx://localhost:3312')

  class Item
    include DataMapper::Resource
    property :id, Serial
    property :name, String
  end

  # Fire up your sphinx search daemon and start searching.
  docs  = repository(:search){ Item.all(:name => 'barney') } # Search 'items' index for '@name barney'
  ids   = docs.map{|doc| doc[:id]}
  items = Item.all(:id => ids) # Search :default for all the document id's returned by sphinx.

=== DataMapper and Is Searchable

  require 'rubygems'
  require 'dm-core'
  require 'dm-is-searchable'
  require 'dm-sphinx-adapter'

  # Connections.
  DataMapper.setup(:default, 'sqlite3::memory:')
  DataMapper.setup(:search, 'sphinx://localhost:3312')

  class Item
    include DataMapper::Resource
    property :id, Serial
    property :name, String

    is :searchable # defaults to :search repository though you can be explicit:
    # is :searchable, :repository => :sphinx
  end

  # Fire up your sphinx search daemon and start searching.
  items = Item.search(:name => 'barney') # Search 'items' index for '@name barney'

=== Merb, DataMapper and Is Searchable

  # config/init.rb
  dependency 'dm-is-searchable'
  dependency 'dm-sphinx-adapter'

  # config/database.yml
  ---
  development: &defaults
    repositories:
      search:
        adapter:  sphinx
        host:     localhost
        port:     3312

  # app/models/item.rb
  class Item
    include DataMapper::Resource
    property :id, Serial
    property :name, String

    is :searchable # defaults to :search repository though you can be explicit:
    # is :searchable, :repository => :sphinx
  end # Item

  # Fire up your sphinx search daemon and start searching.
  Item.search(:name => 'barney') # Search 'items' index for '@name barney'

=== DataMapper::SphinxResource

For finder grained control you can include DataMapper::SphinxResource. For instance you can search one or more indexes:

  class Item
    include DataMapper::Resource # Optional, included by SphinxResource if you leave it out yourself.
    include DataMapper::SphinxResource
    property :id, Serial
    property :name, String

    is :searchable
    repository(:search) do
      index :items
      index :items_delta, :delta => true
    end

  end # Item

  # Fire up your sphinx search daemon and start searching.
  Item.search(:name => 'barney') # Search 'items, items_delta' index for '@name barney'

== Todo

* Declare attributes. DataMapper::Model#property are treated as fields.
* Managed Sphinx search daemon and indexer?
* Give the SphinxAdapter the power to call indexer for live(ish) delta index updates.
* Loads of documentation. YARD?

== Dependencies

dm-core is technically the only requirement though I'd recommend using the dm-more plugin dm-is-searchable instead
of fetching the document id's yourself.

Unfortunately dm-is-searchable isn't installed even when you build the dm-more gem from github master. You'll need to
build and install the gem yourself from source.

== Contributing

Go nuts. Just send me a pull request (github or otherwise) when you are happy with your code.
