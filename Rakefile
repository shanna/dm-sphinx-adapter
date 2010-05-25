require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "dm-sphinx-adapter"
    gem.summary     = %q{A DataMapper Sphinx adapter.}
    gem.email       = "shane.hanna@gmail.com"
    gem.homepage    = "http://github.com/shanna/dm-sphinx-adapter"
    gem.authors     = ["Shane Hanna"]
    gem.executables = [] # Only ever bundled development executables in bin/*
    gem.add_dependency 'dm-core', ['>= 1.0.0.rc2']
    gem.add_dependency 'riddle',  ['~> 1.0.9']
    gem.files.reject!{|f| f=~ %r{test/files/tmp/.*}}
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Run tests.'
task :test do
  Dir.glob(File.join(File.dirname(__FILE__), 'test', '**', 'test_*.rb')){|file| require file}
  MiniTest::Unit.autorun
end

task :default => :test
