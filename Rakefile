# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.new('dm-sphinx-adapter', '0.1') do |p|
  p.developer('Shane Hanna', 'shane.hanna@gmail.com')
  p.extra_deps = [
    ['dm-core', '~> 0.9.7'],
    ['riddle',  '~> 0.9']
  ]
end

# http://blog.behindlogic.com/2008/10/auto-generate-your-manifest-and-gemspec.html
desc 'Rebuild manifest and gemspec.'
task :cultivate do
  Dir.chdir(File.dirname(__FILE__)) do #TODO: Is this required?
    system %q{git ls-files | grep -v "\.gitignore" > Manifest.txt}
    system %q{rake debug_gem | grep -v "(in " > `basename \`pwd\``.gemspec}
  end
end

# vim: syntax=Ruby
