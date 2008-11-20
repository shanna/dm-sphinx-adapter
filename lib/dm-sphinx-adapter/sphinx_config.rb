require 'strscan'
require 'pathname'

# TODO: Error classes.
# TODO: Just warn if a config file can't be found.

module DataMapper
  class SphinxConfig

    ##
    # Read a sphinx configuration file.
    #
    # This class just gives you access to handy searchd {} configuration options. It does not validate your
    # configuration file beyond basic syntax checking.
    def initialize(uri_or_options = {})
      @config  = []
      @searchd = {
        'address'         => '0.0.0.0',
        'log'             => 'searchd.log',
        'max_children'    => 0,
        'max_matches'     => 1000,
        'pid_file'        => nil,
        'port'            => 3312,
        'preopen_indexes' => 0,
        'query_log'       => '',
        'read_timeout'    => 5,
        'seamless_rotate' => 1,
        'unlink_old'      => 1
      }

      path = case uri_or_options
        when Addressable::URI, DataObjects::URI then uri_or_options.path
        when Hash                               then uri_or_options[:config] || uri_or_options[:database]
        when Pathname                           then uri_or_options
        when String                             then DataObjects::URI.parse(uri_or_options).path
      end
      parse('' + path.to_s) # Force stringy since Pathname#to_s is broken IMO.
    end

    ##
    # Configuration file full path name.
    #
    # @return [String]
    def config
      @config
    end

    ##
    # Indexer binary full path name and config argument.
    def indexer_bin(use_config = true)
      path = 'indexer' # TODO: Real.
      path << " --config #{config}" if config
      path
    end

    ##
    # Searchd binardy full path name and config argument.
    def searchd_bin(use_config = true)
      path = 'searchd' # TODO: Real.
      path << " --config #{config}" if config
      path
    end

    ##
    # Searchd address.
    def address
      searchd['address']
    end

    ##
    # Searchd port.
    def port
      searchd['port']
    end

    ##
    # Searchd pid_file.
    def pid_file
      searchd['pid_file'] or raise "Mandatory pid_file option missing from searchd configuration."
    end

    ##
    # Searchd log file.
    def log
      searchd['log']
    end

    ##
    # Searchd configuration options.
    #
    # @see http://www.sphinxsearch.com/doc.html#confgroup-searchd
    def searchd
      @searchd
    end

    protected

      ##
      # Parse a sphinx config file.
      #
      # @param [String] path Searches path, ./path, /path, /usr/local/etc/sphinx.conf, ./sphinx.conf in that order.
      def parse(path = '')
        # TODO: Three discrete things going on here, should be three subs.
        paths = [
          path,
          path.gsub(%r{^/}, './'),
          path.gsub(%r{^\./}, '/'),
          '/usr/local/etc/sphinx.conf', # TODO: Does this one depend on where searchd/indexer is installed?
          './sphinx.conf'
        ]
        paths.find do |path|
          @config = Pathname.new(path).expand_path
          @config.readable? && `#{indexer_bin}` !~ /fatal|error/i
        end or raise IOError, %{No readable config file (looked in #{paths.join(', ')})}

        source = config.read
        source.gsub!(/\r\n|\r|\n/, "\n") # Everything in \n
        source.gsub!(/\s*\\\n\s*/, ' ')  # Remove unixy line wraps.
        @in = StringScanner.new(source)
        blocks(blocks = [])
        @in = nil

        searchd = blocks.find{|c| c['type'] =~ /searchd/i} || {}
        @searchd.update(searchd)
      end

    private

      def blocks(out = []) #:nodoc:
        if @in.scan(/\#[^\n]*\n/) || @in.scan(/\s+/)
          blocks(out)
        elsif @in.scan(/indexer|searchd|source|index/i)
          out << group = {'type' => @in.matched}
          if @in.matched =~ /^(?:index|source)$/i
            @in.scan(/\s* ([\w_\-]+) (?:\s*:\s*([\w_\-]+))? \s*/x) or raise "Expected #{group[:type]} name."
            group['name']     = @in[1]
            group['ancestor'] = @in[2]
          end
          @in.scan(/\s*\{/) or raise %q{Expected '\{'.}
          pairs(kv = {})
          group.merge!(kv)
          @in.scan(/\s*\}/) or raise %q{Expected '\}'.}
          blocks(out)
        else
          raise "Unknown near: #{@in.peek(30)}" unless @in.eos?
        end
      end

      def pairs(out = {}) #:nodoc:
        if @in.scan(/\#[^\n]*\n/) || @in.scan(/\s+/)
          pairs(out)
        elsif @in.scan(/[\w_-]+/)
          key = @in.matched
          @in.scan(/\s*=/) or raise %q{Expected '='.}
          out[key] = @in.scan(/[^\n]*\n/).strip
          pairs(out)
        end
      end
  end # SphinxConfig
end # DataMapper
