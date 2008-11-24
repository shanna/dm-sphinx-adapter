require 'rubygems'

# TODO: Hide the shitload of dm-core warnings or at least try to?
$VERBOSE = nil
gem 'dm-core', '~> 0.9.7'
require 'dm-core'

# TODO: I think I might move everything to DataMapper::Sphinx::* and ignore the default naming convention.
require 'pathname'
dir = Pathname(__FILE__).dirname.expand_path / 'dm-sphinx-adapter'
require dir / 'config'
require dir / 'config_parser'
require dir / 'client'
require dir / 'adapter'
require dir / 'index'
require dir / 'attribute'
require dir / 'resource'

