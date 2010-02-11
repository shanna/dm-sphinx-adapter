require 'rubygems'
require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "dm-sphinx-adapter"
    gem.summary     = %q{A DataMapper Sphinx adapter.}
    gem.email       = "shane.hanna@gmail.com"
    gem.homepage    = "http://github.com/shanna/dm-sphinx-adapter"
    gem.authors     = ["Shane Hanna"]
    gem.executables = [] # Only ever bundled development executables in bin/*
    gem.add_dependency 'dm-core', ['~> 0.10.2']
    gem.add_dependency 'riddle',  ['~> 1.0.9']
    gem.files.reject!{|f| f=~ %r{test/files/tmp/.*}}
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
