# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-raw-upload}
  s.version = "1.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Pablo Brasero}]
  s.date = %q{2011-07-30}
  s.description = %q{Middleware that converts files uploaded with mimetype application/octet-stream into normal form input, so Rack applications can read these as normal, rather than as raw input.}
  s.email = %q{pablobm@gmail.com}
  s.extra_rdoc_files = [%q{LICENSE}, %q{README.md}]
  s.files = [%q{LICENSE}, %q{README.md}]
  s.homepage = %q{https://github.com/newbamboo/rack-raw-upload}
  s.rdoc_options = [%q{--charset=UTF-8}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.7}
  s.summary = %q{Rack Raw Upload middleware}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
