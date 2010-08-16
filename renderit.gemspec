# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{renderit}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrey Romanov"]
  s.date = %q{2010-08-16}
  s.description = %q{Renders different templates depending on browser user_agent.}
  s.email = %q{judo.ras@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/renderit.rb",
     "renderit.gemspec",
     "spec/config/renderit.yml",
     "spec/renderit_spec.rb",
     "spec/spec_helper.rb",
     "spec/spec_initializer.rb"
  ]
  s.homepage = %q{http://github.com/romanoff/renderit}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Renders different templates depending on browser user_agent.}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/renderit_spec.rb",
     "spec/spec_initializer.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

