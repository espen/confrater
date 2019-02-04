# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'confrere/version'

Gem::Specification.new do |s|
  s.name        = "Confrere"
  s.version     = Confrere::VERSION
  s.authors     = ["Espen Antonsen", "Amro Mousa"]
  s.homepage    = "http://github.com/espen/confrere"

  s.summary     = %q{A wrapper for Confrere API}
  s.description = %q{A wrapper for Confrere API}
  s.license     = "MIT"

  s.rubyforge_project = "confrere"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency('faraday')
  s.add_dependency('multi_json')

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'

end
