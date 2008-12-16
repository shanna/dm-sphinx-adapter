# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-sphinx-adapter}
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2008-12-16}
  s.description = %q{A DataMapper Sphinx adapter.}
  s.email = ["shane.hanna@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "LICENCE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENCE.txt", "Manifest.txt", "README.txt", "Rakefile", "dm-sphinx-adapter.gemspec", "lib/dm-sphinx-adapter.rb", "lib/dm-sphinx-adapter/adapter.rb", "lib/dm-sphinx-adapter/attribute.rb", "lib/dm-sphinx-adapter/index.rb", "lib/dm-sphinx-adapter/query.rb", "lib/dm-sphinx-adapter/resource.rb", "lib/riddle.rb", "lib/riddle/client.rb", "lib/riddle/client/filter.rb", "lib/riddle/client/message.rb", "lib/riddle/client/response.rb", "test/files/model.rb", "test/files/mysql5.sphinx.conf", "test/files/mysql5.sql", "test/helper.rb", "test/test_adapter.rb", "test/test_attribute.rb", "test/test_index.rb", "test/test_query.rb", "test/test_resource.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://dm-sphinx.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dm-sphinx-adapter}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{A DataMapper Sphinx adapter.}
  s.test_files = ["test/test_adapter.rb", "test/test_attribute.rb", "test/test_index.rb", "test/test_query.rb", "test/test_resource.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.9.7"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.9.7"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.9.7"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
