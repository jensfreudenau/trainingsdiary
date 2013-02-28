# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{numerizer}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{John Duff}]
  s.date = %q{2010-01-01}
  s.description = %q{Numerizer is a gem to help with parsing numbers in natural language from strings (ex forty two). It was extracted from the awesome Chronic gem http://github.com/evaryont/chronic.}
  s.email = %q{duff.john@gmail.com}
  s.extra_rdoc_files = [%q{LICENSE}, %q{README.rdoc}]
  s.files = [%q{LICENSE}, %q{README.rdoc}]
  s.homepage = %q{http://github.com/jduff/numerizer}
  s.rdoc_options = [%q{--charset=UTF-8}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.7}
  s.summary = %q{Numerizer is a gem to help with parsing numbers in natural language from strings (ex forty two).}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
