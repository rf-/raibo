# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "raibo/version"

Gem::Specification.new do |s|
  s.name        = "raibo"
  s.version     = Raibo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ryan Fitzgerald"]
  s.email       = ["rwfitzge@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A simple IRC library}
  s.description = %q{}

  s.rubyforge_project = "raibo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'tinder'

  s.add_development_dependency 'rspec'
end
