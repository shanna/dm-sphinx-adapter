= DataMapper Sphinx Adapter

* http://rubyforge.org/projects/dm-sphinx/
* http://github.com/shanna/dm-sphinx-adapter/tree/master

== Description

A DataMapper Sphinx adapter.

== Dependencies

* dm-core           ~> 0.9.7
* riddle            ~> 0.9
* daemon_controller ~> 0.2   (optional)
* dm-is-searchable  ~> 0.9.7 (optional)

I'd recommend using the dm-more plugin dm-is-searchable instead of fetching the document id's yourself.

== Install

* Via git: git clone git://github.com/shanna/iso-country-codes.git
* Via gem: gem install shanna-dm-sphinx-adapter -s http://gems.github.com

== Synopsis

DataMapper uses URIs or a connection has to connect to your data-stores. In this case the sphinx search daemon
<tt>searchd</tt>.

On its own this adapter will only return an array of document hashes when queried. The DataMapper library dm-more
however provides dm-is-searchable, a common interface to search one adapter and load documents from another. My
preference is to use this adapter in tandem with dm-is-searchable.

Like all DataMapper adapters you can connect with a Hash or URI.

A URI:
  DataMapper.setup(:search, 'sphinx://localhost')

The breakdown is:
  "#{adapter}://#{host}:#{port}/#{config}"
  - adapter Must be :sphinx
  - host    Hostname (default: localhost)
  - port    Optional port number (default: 3312)
  - config  Optional but strongly recommended path to sphinx config file.

Alternatively supply a Hash:
  DataMapper.setup(:search, {
    :adapter  => 'sphinx',       # required
    :config   => './sphinx.conf' # optional. Recommended though.
    :host     => 'localhost',    # optional. Default: localhost
    :port     => 3312            # optional. Default: 3312
    :managed  => true            # optional. Self managed searchd server using daemon_controller.
  }

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

For finer grained control you can include DataMapper::SphinxResource. For instance you can search one or more indexes
and sort, include or exclude by attributes defined in your sphinx configuration:

  class Item
    include DataMapper::Resource # Optional, included by SphinxResource if you leave it out yourself.
    include DataMapper::SphinxResource
    property :id, Serial
    property :name, String

    is :searchable
    repository(:search) do
      index :items
      index :items_delta, :delta => true

      # Sphinx attributes to sort include/exclude by.
      attribute :updated_on, DateTime
    end

  end # Item

  # Search 'items, items_delta' index for '@name barney' updated in the last 30 minutes.
  Item.search(:name => 'barney', :updated => (Time.now - 1800 .. Time.now))

== Sphinx Configuration

Though you don't have to supply the sphinx configuration file to dm-sphinx-adapter I'd recommend doing it anyway.
It's more DRY since all searchd/indexer options can be read straight from the configuration.

  DataMapper.setup(:search, :adapter => 'sphinx', :config => '/path/to/sphinx.conf')
  DataMapper.setup(:search, 'sphinx://localhost/path/to/sphinx.conf')

If your sphinx.conf lives in either of the default locations /usr/local/etc/sphinx.conf or ./sphinx.conf then you
only need to supply:

  DataMapper.setup(:search, :adapter => 'sphinx')

== Searchd

As of 0.2 I've added a managed searchd option using daemon_controller. It may come in handy if you only use God, Monit
or whatever in production. Use the Hash form of DataMapper#setup and supply the option :managed with a true value and
daemon_controller will start searchd on demand.

It is already strongly encouraged but you will need to specify the path to your sphinx configuration file in order for
searchd to run. See Sphinx Configuration, DataMapper::Adapters::Sphinx::ManagedClient.

The daemon_controller library can be found only on github, not rubyforge.
See http://github.com/FooBarWidget/daemon_controller/tree/master

== Indexer and Live(ish) updates.

As of 0.3 the indexer will no longer be fired on create/update even if you have delta indexes defined. Sphinx indexing
is blazing fast but unless your resource sees very little activity you will run the risk of lock errors on
the temporary delta index files (.tmpl.sp1) and your delta index won't be updated. Given this functionality is
unreliable at best I've chosen to remove it.

For reliable live(ish) updates in a main + delta scheme it's probably best you schedule them outside of your ORM.
Andrew (Shodan) Aksyonoff of Sphinx suggests a cronjob or alternatively if you need even less lag to "run indexer in
an endless loop, with a few seconds of sleep in between to allow searchd some headroom to pick up the changes".

== Todo

* Loads of documentation. Most of it is unchecked YARD at the moment.
* Add DataMapper::Adapters::Sphinx::Client#attribute_set to allow attribute modification on one or more indexes. It's
  the only thing missing if you understand the pitfalls and still want to add thinking-sphinx like delta indexing to
  your resource.

== Contributing

Go nuts. Just send me a pull request (github or otherwise) when you are happy with your code.

