# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{numerizer}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Duff"]
  s.date = %q{2010-01-01}
  s.description = %q{Numerizer is a gem to help with parsing numbers in natural language from strings (ex forty two). It was extracted from the awesome Chronic gem http://github.com/evaryont/chronic.}
  s.email = %q{duff.john@gmail.com}
  s.files = ["test/test_helper.rb", "test/test_numerizer.rb"]
  s.homepage = %q{http://github.com/jduff/numerizer}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Numerizer is a gem to help with parsing numbers in natural language from strings (ex forty two).}
  s.test_files = ["test/test_helper.rb", "test/test_numerizer.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
