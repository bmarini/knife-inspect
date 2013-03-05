# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "health_inspector/version"

Gem::Specification.new do |s|
  s.name        = "knife-inspect"
  s.version     = HealthInspector::VERSION
  s.authors     = ["Ben Marini"]
  s.email       = ["bmarini@gmail.com"]
  s.homepage    = "https://github.com/bmarini/knife-inspect"
  s.summary     = %q{Inspect your chef repo as is compares to what is on your chef server}
  s.description = %q{Inspect your chef repo as is compares to what is on your chef server}

  s.rubyforge_project = "knife-inspect"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "chef", ['>= 10.14', '<= 12']
  s.add_runtime_dependency "yajl-ruby"
end
