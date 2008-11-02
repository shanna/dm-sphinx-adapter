= DataMapper Sphinx Adapter

A Sphinx DataMapper adapter.

== Synopsis

DataMapper uses URIs or a connection has to connect to your data-stores. In this case the sphinx search daemon
<tt>searchd</tt>.

On its own this adapter will only return an array of document IDs when queried. The dm-more source (not the gem)
however provides dm-is-searchable, a common interface to search one adapter and load documents from another. My
suggestion is to use this adapter in tandem with dm-is-searchable.

The dm-is-searchable plugin is part of dm-more though unfortunately isn't built and bundled with dm-more gem.
You'll need to checkout the dm-more source with Git from git://github.com/sam/dm-more.git and build/install the
gem yourself.

  git clone git://github.com/sam/dm-more.git
  cd dm-more/dm-is-searchable
  sudo rake install_gem

Like all DataMapper adapters you can connect with a Hash or URI.

A URI:
  DataMapper.setup(:search, 'sphinx://localhost')

The breakdown is:
  "#{adapter}://#{host}:#{port}/#{config}"
  - adapter Must be :sphinx
  - host    Hostname (default: localhost)
  - port    Optional port number (default: 3312)

Alternatively supply a Hash:
  DataMapper.setup(:search, {
    :adapter  => 'sphinx',    # required
    :host     => 'localhost', # optional (default: localhost)
    :port     => 3312         # optional (default: 3312(
  })

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
