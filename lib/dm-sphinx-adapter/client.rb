module DataMapper
  module Adapters
    module Sphinx
      # Client wrapper for Riddle::Client.
      #
      # * Simple interface to +searchd+ *and* +indexer+.
      # * Can read +searchd+ configuration options from your sphinx configuration file.
      # * Managed +searchd+ using +daemon_controller+ for on demand daemon control in development.
      class Client

        # ==== Parameters
        # uri_or_options<URI, DataObject::URI, Addressable::URI, String, Hash, Pathname>::
        #   DataMapper uri or options hash.
        def initialize(uri_or_options = {})
          @config = Sphinx::Config.new(uri_or_options)
        end

        # Search one or more indexes.
        #
        # ==== See
        # * Riddle::Client
        #
        # ==== Parameters
        # query<String>:: A sphinx query string.
        # indexes<Array, String>:: Indexes to search. Default is '*' all.
        # options<Hash>:: Any attributes supported by the Riddle::Client.
        #
        # ==== Returns
        # Hash:: Riddle::Client#query response struct.
        def search(query, indexes = '*', options = {})
          indexes = indexes.join(' ') if indexes.kind_of?(Array)

          client = Riddle::Client.new(@config.address, @config.port)
          options.each{|k, v| client.method("#{k}=".to_sym).call(v) if client.respond_to?("#{k}=".to_sym)}
          client.query(query, indexes.to_s)
        end

        # Index one or more indexes.
        #
        # ==== Parameters
        # indexes<Array, String>:: Indexes to index (and rotate). Defaults to --all if indexes is +nil+ or '*'.
        def index(indexes = nil)
          indexes = indexes.join(' ') if indexes.kind_of?(Array)

          command = @config.indexer_bin
          command << " --rotate" if running?
          command << ((indexes.nil? || indexes == '*') ? ' --all' : " #{indexes.to_s}")
          warn "Sphinx: Indexer #{$1}" if `#{command}` =~ /(?:error|fatal|warning):?\s*([^\n]+)/i
        end

        protected
          # Is a +searchd+ daemon running on the configured address and port.
          #
          # ==== Notes
          # This is a simple TCPSocket test. It may not be your +searchd+ deamon or even a +searchd+ daemon at all if
          # your configuration is wrong or another +searchd+ daemon is listen on that port already.
          #
          # ==== Returns
          # Boolean
          def running?
            !!TCPSocket.new(@config.address, @config.port) rescue nil
          end
      end # Client

      # Managed searchd if you don't already have god/monit doing the job for you.
      #
      # Requires you have +daemon_controller+ installed.
      #
      # ==== See
      # * http://github.com/FooBarWidget/daemon_controller/tree/master
      class ManagedClient < Client

        # ==== See
        # * DataMapper::Adapters::Sphinx::Client#new
        def initialize(url_or_options = {})
          super

          require 'daemon_controller'
          @client = DaemonController.new(
            :identifier    => 'Sphinx searchd',
            :start_command => @config.searchd_bin,
            :stop_command  => "#{@config.searchd_bin} --stop",
            :ping_command  => method(:running?),
            :pid_file      => @config.pid_file,
            :log_file      => @config.log
          )
        end

        # Start the +searchd+ daemon if it isn't already running then search.
        #
        # ==== See
        # * DataMapper::Adapters::Sphinx::Client#search
        def search(*args)
          @client.connect{super}
        end

        # Stop the +searchd+ daemon if it's running.
        def stop
          @client.stop if @client.running?
        end
      end # ManagedClient
    end # Sphinx
  end # Adapters
end # DataMapper
