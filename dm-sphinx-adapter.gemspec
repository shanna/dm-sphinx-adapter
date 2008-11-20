# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-sphinx-adapter}
  s.version = "0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2008-11-20}
  s.description = %q{}
  s.email = ["shane.hanna@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "LICENCE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENCE.txt", "Manifest.txt", "README.txt", "Rakefile", "dm-sphinx-adapter.gemspec", "lib/dm-sphinx-adapter.rb", "lib/dm-sphinx-adapter/sphinx_adapter.rb", "lib/dm-sphinx-adapter/sphinx_attribute.rb", "lib/dm-sphinx-adapter/sphinx_client.rb", "lib/dm-sphinx-adapter/sphinx_config.rb", "lib/dm-sphinx-adapter/sphinx_index.rb", "lib/dm-sphinx-adapter/sphinx_resource.rb", "test/data/sphinx.conf", "test/fixtures/item.rb", "test/fixtures/item.sql", "test/fixtures/item_resource_explicit.rb", "test/fixtures/item_resource_only.rb", "test/helper.rb", "test/test_client.rb", "test/test_config.rb", "test/test_search.rb"]
  s.has_rdoc = true
  s.homepage = %q{A Sphinx DataMapper adapter.}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dm-sphinx-adapter}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{}
  s.test_files = ["test/test_client.rb", "test/test_config.rb", "test/test_search.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<riddle>, ["~> 0.9"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.9.7"])
      s.add_dependency(%q<riddle>, ["~> 0.9"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.9.7"])
    s.add_dependency(%q<riddle>, ["~> 0.9"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
