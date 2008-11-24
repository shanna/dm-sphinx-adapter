# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-sphinx-adapter}
  s.version = "0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2008-11-24}
  s.description = %q{A DataMapper Sphinx adapter.}
  s.email = ["shane.hanna@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "LICENCE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENCE.txt", "Manifest.txt", "README.txt", "Rakefile", "dm-sphinx-adapter.gemspec", "lib/dm-sphinx-adapter.rb", "lib/dm-sphinx-adapter/adapter.rb", "lib/dm-sphinx-adapter/attribute.rb", "lib/dm-sphinx-adapter/client.rb", "lib/dm-sphinx-adapter/config.rb", "lib/dm-sphinx-adapter/config_parser.rb", "lib/dm-sphinx-adapter/index.rb", "lib/dm-sphinx-adapter/resource.rb", "test/files/dm_sphinx_adapter_test.sql", "test/files/resource_explicit.rb", "test/files/resource_resource.rb", "test/files/resource_searchable.rb", "test/files/resource_storage_name.rb", "test/files/resource_vanilla.rb", "test/files/sphinx.conf", "test/test_adapter.rb", "test/test_adapter_explicit.rb", "test/test_adapter_resource.rb", "test/test_adapter_searchable.rb", "test/test_adapter_vanilla.rb", "test/test_client.rb", "test/test_config.rb", "test/test_config_parser.rb", "test/test_type_attribute.rb", "test/test_type_index.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyforge.org/projects/dm-sphinx/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dm-sphinx-adapter}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{A DataMapper Sphinx adapter.}
  s.test_files = ["test/test_adapter.rb", "test/test_adapter_explicit.rb", "test/test_adapter_resource.rb", "test/test_adapter_searchable.rb", "test/test_adapter_vanilla.rb", "test/test_client.rb", "test/test_config.rb", "test/test_config_parser.rb", "test/test_type_attribute.rb", "test/test_type_index.rb"]

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
