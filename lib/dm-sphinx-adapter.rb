require 'rubygems'

# TODO: Hide the shitload of dm-core warnings or at least try to?
$VERBOSE = nil
gem 'dm-core', '~> 0.9.7'
require 'dm-core'

gem 'riddle', '~> 0.9'
require 'riddle'

require 'pathname'
dir = Pathname(__FILE__).dirname.expand_path / 'dm-sphinx-adapter'
require dir / 'sphinx_adapter'
require dir / 'sphinx_index'
require dir / 'sphinx_resource'

