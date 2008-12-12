require 'rubygems'

# TODO: Hide the shitload of dm-core warnings or at least try to?
$VERBOSE = nil
gem 'dm-core', '~> 0.9.7'
require 'dm-core'

require 'pathname'
lib = Pathname(__FILE__).dirname.expand_path
dir = lib / 'dm-sphinx-adapter'

# Bundled Riddle since the gem is very old and we don't need any of the config generation stuff.
$:.unshift lib
require 'riddle'

# TODO: Require farms suck. Do something about it.
require dir / 'adapter'
require dir / 'attribute'
require dir / 'index'
require dir / 'query'
require dir / 'resource'
