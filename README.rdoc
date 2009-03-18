= DataMapper Sphinx Adapter

* http://dm-sphinx.rubyforge.org
* http://rubyforge.org/projects/dm-sphinx
* http://github.com/shanna/dm-sphinx-adapter/tree/master

== Description

A DataMapper Sphinx adapter.

== Dependencies

Ruby::
* dm-core           ~> 0.9.7
* dm-is-searchable  ~> 0.9.7 (optional)

I'd recommend using the dm-more plugin dm-is-searchable instead of fetching the document id's yourself.

Sphinx::
* 0.9.8-r871
* 0.9.8-r909
* 0.9.8-r985
* 0.9.8-r1065
* 0.9.8-r1112
* 0.9.8-rc1 (gem version: 0.9.8.1198)
* 0.9.8-rc2 (gem version: 0.9.8.1231)
* 0.9.8 (gem version: 0.9.8.1371)

Internally the Riddle client library is used.

== Install

* Via git: git clone git://github.com/shanna/dm-sphinx-adapter.git
* Via gem: gem install shanna-dm-sphinx-adapter -s http://gems.github.com

== Synopsis

DataMapper uses URIs or a connection has to connect to your data-stores. In this case the sphinx search daemon
<tt>searchd</tt>.

On its own this adapter will only return an array of document hashes when queried. The DataMapper library
<tt>dm-is-searchable</tt> however provides a common interface to search one adapter and load documents from another. My
preference is to use this adapter in tandem with <tt>dm-is-searchable</tt>. See further examples in the synopsis for
usage with <tt>dm-is-searchable</tt>.

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
    :adapter  => 'sphinx',       # required
    :config   => './sphinx.conf' # optional. Recommended though.
    :host     => 'localhost',    # optional. Default: localhost
    :port     => 3312            # optional. Default: 3312
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

=== DataMapper and IsSearchable

IsSearchable is a DataMapper plugin that provides a common search interface when searching from one adapter and reading
documents from another.

IsSearchable will read resources from your <tt>:default</tt> repository on behalf of a search adapter such as
<tt>dm-sphinx-adapter</tt> and <tt>dm-ferret-adapter</tt>. This saves some of the grunt work (as shown in the previous
example) by mapping the resulting document id's from a search with your <tt>:search</tt> adapter into a suitable
<tt>#first</tt> or <tt>#all</tt> query for your <tt>:default</tt> repository.

IsSearchable adds a single class method to your resource. The first argument is a <tt>Hash</tt> of
<tt>DataMapper::Query</tt> conditions to pass to your search adapter (in this case <tt>dm-sphinx-adapter</tt>). An
optional second <tt>Hash</tt> of <tt>DataMapper::Query</tt> conditions can also be passed and will be appended to the
query on your <tt>:default</tt> database. This can be handy if you need to add extra exclusions that aren't possible
using <tt>dm-sphinx-adapter</tt> such as <tt>#gt</tt> or <tt>#lt</tt> conditions.

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

=== Merb, DataMapper and IsSearchable

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

=== DataMapper, IsSearchable and DataMapper::SphinxResource

For finer grained control you can include DataMapper::SphinxResource. For instance you can search one or more indexes
and sort, include or exclude by attributes defined in your sphinx configuration:

  class Item
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

No limitations, restrictions or requirement are imposed on your sphinx configuration. The adapter will not generate nor
overwrite your finely crafted config file.

== Searchd

To keep things simple, this adapter does not manage your sphinx server. Try one of these fine offerings:

* god[http://god.rubyforge.org]
* daemon_controller[http://github.com/FooBarWidget/daemon_controller/tree/master]
* monit[http://www.tildeslash.com/monit]

== Indexer and Live(ish) updates.

As of 0.3 the indexer will no longer be fired on create/update even if you have delta indexes defined. Sphinx indexing
is blazing fast but unless your resource sees very little activity you will run the risk of lock errors on
the temporary delta index files (.tmpl.sp1) and your delta index won't be updated. Given this functionality is
unreliable at best I've chosen to remove it.

For reliable live(ish) updates in a main + delta scheme it's probably best you schedule them outside of your ORM.
Andrew (Shodan) Aksyonoff of Sphinx suggests a cronjob or alternatively if you need even less lag to "run indexer in
an endless loop, with a few seconds of sleep in between to allow searchd some headroom to pick up the changes".

== Contributing

Go nuts. Just send me a pull request (github or otherwise) when you are happy with your code.

