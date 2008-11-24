require 'rubygems'

gem 'extlib', '~> 0.9.7'
require 'extlib'

module DataMapper
  module Adapters
    module Sphinx
      class Config
        include Extlib::Assertions
        attr_reader :config, :address, :log, :port

        ##
        # Read a sphinx configuration file.
        #
        # This class just gives you access to handy searchd {} configuration options.
        #
        # @see http://www.sphinxsearch.com/doc.html#confgroup-searchd
        def initialize(uri_or_options = {})
          assert_kind_of 'uri_or_options', uri_or_options, Addressable::URI, DataObjects::URI, Hash, String, Pathname

          options   = normalize_options(uri_or_options)
          config    = parse_config("#{options[:path]}") # Pathname#to_s is broken?
          @address  = options[:host]     || config['address']  || '0.0.0.0'
          @port     = options[:port]     || config['port']     || 3312
          @log      = options[:log]      || config['log']      || 'searchd.log'
          @pid_file = options[:pid_file] || config['pid_file']
        end

        ##
        # Indexer binary full path name and config argument.
        def indexer_bin(use_config = true)
          path = 'indexer' # TODO: Real.
          path << " --config #{config}" if config
          path
        end

        ##
        # Searchd binary full path name and config argument.
        def searchd_bin(use_config = true)
          path = 'searchd' # TODO: Real.
          path << " --config #{config}" if config
          path
        end

        def pid_file
          @pid_file or raise "Mandatory pid_file option missing from searchd configuration."
        end

        protected
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
