# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{itslog}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Thomas Marino"]
  s.date = %q{2011-06-28}
  s.description = %q{
    `itslog` is a log formatter designed to aid rails 3 development.
  }
  s.email = %q{writejm@gmail.com}
  s.homepage = %q{http://github.com/johmas/itslog}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{itslog}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{itslog makes logs more useful for rails 3 development.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
