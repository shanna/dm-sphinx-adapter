require 'rubygems'

gem 'extlib', '~> 0.9.7'
require 'extlib'

require 'pathname'
require 'strscan'

module DataMapper
  module Adapters
    module Sphinx
      module ConfigParser
        extend Extlib::Assertions

        ##
        # Parse a sphinx config file and return searchd options as a hash.
        #
        # @param  [String] path Searches path, ./#{path}, /#{path}, /usr/local/etc/sphinx.conf, ./sphinx.conf in
        # that order.
        # @return [Hash]
        def self.parse(path)
          assert_kind_of 'path', path, Pathname, String

          config = Pathname(path).read
          config.gsub!(/\r\n|\r|\n/, "\n") # Everything in \n
          config.gsub!(/\s*\\\n\s*/, ' ')  # Remove unixy line wraps.

          blocks(StringScanner.new(config), out = [])
          out.find{|c| c['type'] =~ /searchd/i} || {}
        end

        protected
          def self.blocks(conf, out = []) #:nodoc:
            if conf.scan(/\#[^\n]*\n/) || conf.scan(/\s+/)
              blocks(conf, out)
            elsif conf.scan(/indexer|searchd|source|index/i)
              out << group = {'type' => conf.matched}
              if conf.matched =~ /^(?:index|source)$/i
                conf.scan(/\s* ([\w_\-]+) (?:\s*:\s*([\w_\-]+))? \s*/x) or raise "Expected #{group[:type]} name."
                group['name']     = conf[1]
                group['ancestor'] = conf[2]
              end
              conf.scan(/\s*\{/) or raise %q{Expected '\{'.}
              pairs(conf, kv = {})
              group.merge!(kv)
              conf.scan(/\s*\}/) or raise %q{Expected '\}'.}
              blocks(conf, out)
            else
              raise "Unknown near: #{conf.peek(30)}" unless conf.eos?
            end
          end

          def self.pairs(conf, out = {}) #:nodoc:
            if conf.scan(/\#[^\n]*\n/) || conf.scan(/\s+/)
              pairs(conf, out)
            elsif conf.scan(/[\w_-]+/)
              key = conf.matched
              conf.scan(/\s*=/) or raise %q{Expected '='.}
              out[key] = conf.scan(/[^\n]*\n/).strip
              pairs(conf, out)
            end
          end
      end # ConfigParser
    end # Sphinx
  end # Adapters
end # DataMapper

