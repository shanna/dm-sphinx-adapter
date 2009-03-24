# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-sphinx-adapter}
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2009-03-25}
  s.email = %q{shane.hanna@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["VERSION.yml", "README.rdoc", "lib/dm-sphinx-adapter.rb", "lib/riddle", "lib/riddle/client", "lib/riddle/client/filter.rb", "lib/riddle/client/message.rb", "lib/riddle/client/response.rb", "lib/riddle/client.rb", "lib/riddle.rb", "lib/dm-sphinx-adapter", "lib/dm-sphinx-adapter/resource.rb", "lib/dm-sphinx-adapter/attribute.rb", "lib/dm-sphinx-adapter/query.rb", "lib/dm-sphinx-adapter/xmlpipe2.rb", "lib/dm-sphinx-adapter/index.rb", "lib/dm-sphinx-adapter/adapter.rb", "test/test_query.rb", "test/test_resource.rb", "test/test_attribute.rb", "test/test_xmlpipe2.rb", "test/helper.rb", "test/files", "test/files/test_xmlpipe2.xml", "test/files/model.rb", "test/files/source.xml", "test/files/sphinx.conf", "test/files/tmp", "test/files/tmp/sphinx.query.log", "test/files/tmp/sphinx.pid", "test/files/tmp/sphinx.log", "test/test_index.rb", "test/test_adapter.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/shanna/dm-sphinx-adapter}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A DataMapper Sphinx adapter.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.9"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.9"])
  end
end
