require 'rubygems'

gem 'extlib', '~> 0.9.7'
require 'extlib'

module DataMapper
  module Adapters
    module Sphinx
      class Config
        include Extlib::Assertions

        # Configuration option.
        attr_reader :config, :address, :log, :port

        # Sphinx configuration options.
        #
        # This class just gives you access to handy searchd {} configuration options. If a sphinx configuration file
        # is passed and can be parsed +searchd+ options will be set straight from the file.
        #
        # ==== Notes
        # Option precedence is:
        # * The options hash.
        # * The configuration file.
        # * Sphinx defaults.
        #
        # ==== See
        # http://www.sphinxsearch.com/doc.html#confgroup-searchd
        #
        # ==== Parameters
        # uri_or_options<URI, DataObject::URI, Addressable::URI, String, Hash, Pathname>::
        #   DataMapper uri or options hash.
        def initialize(uri_or_options = {})
          assert_kind_of 'uri_or_options', uri_or_options, Addressable::URI, DataObjects::URI, Hash, String, Pathname

          options   = normalize_options(uri_or_options)
          config    = parse_config("#{options[:path]}") # Pathname#to_s is broken?
          @address  = options[:host]     || config['address']  || '0.0.0.0'
          @port     = options[:port]     || config['port']     || 3312
          @log      = options[:log]      || config['log']      || 'searchd.log'
          @pid_file = options[:pid_file] || config['pid_file']
        end

        # Indexer binary full path name and config argument.
        #
        # ==== Parameters
        # use_config<Boolean>:: Return <tt>--config path/to/config.conf</tt> as part of string. Default +true+.
        #
        # ==== Returns
        # String
        def indexer_bin(use_config = true)
          path = 'indexer' # TODO: Real.
          path << " --config #{config}" if config
          path
        end

        # Searchd binary full path name and config argument.
        #
        # ==== Parameters
        # use_config<Boolean>:: Return <tt>--config path/to/config.conf</tt> as part of string. Default +true+.
        #
        # ==== Returns
        # String
        def searchd_bin(use_config = true)
          path = 'searchd' # TODO: Real.
          path << " --config #{config}" if config
          path
        end

        # Full path to pid_file.
        #
        # ==== Raises
        # RuntimeError:: If a pid file was not read or set. pid_file is a mandatory searchd option in a sphinx
        #   configuration file.
        def pid_file
          @pid_file or raise "Mandatory pid_file option missing from searchd configuration."
        end

        protected
          # Coerce +uri_or_options+ into a +Hash+ of options.
          #
          # ==== Parameters
          # uri_or_options<URI, DataObject::URI, Addressable::URI, String, Hash, Pathname>::
          #   DataMapper uri or options hash.
          #
          # ==== Returns
          # Hash
          def normalize_options(uri_or_options)
            case uri_or_options
              when String, Addressable::URI then DataObjects::URI.parse(uri_or_options).attributes
              when DataObjects::URI         then uri_or_options.attributes
              when Pathname                 then {:path => uri_or_options}
              else
                uri_or_options[:path] ||= uri_or_options.delete(:config) || uri_or_options.delete(:database)
                uri_or_options
            end
          end

          # Reads your sphinx configuration file if given.
          #
          # Also searches default sphinx configuration locations for a config file to parse.
          #
          # ==== See
          # * DataMapper::Adapters::Sphinx::ConfigParser
          #
          # ==== Parameters
          # path<String>:: Path to your configuration file.
          #
          # ==== Returns
          # Hash
          def parse_config(path)
            paths = []
            paths.push(path, path.gsub(%r{^/}, './'), path.gsub(%r{^\./}, '/')) unless path.blank?
            paths.push('/usr/local/etc/sphinx.conf', './sphinx.conf')
            paths.map!{|path| Pathname.new(path).expand_path}

            @config = paths.find{|path| path.readable? && `#{indexer_bin} --config #{path}` !~ /fatal|error/i}
            @config ? ConfigParser.parse(@config) : {}
          end
      end # Config
    end # Sphinx
  end # Adapters
end # DataMapper
