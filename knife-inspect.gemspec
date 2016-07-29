# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "health_inspector/version"

# Allow to pass an arbitrary chef version. Useful for testing for example.
chef_version = if ENV.key?('CHEF_VERSION')
                 "= #{ENV['CHEF_VERSION']}"
               else
                 '>= 12.0.0'
               end

Gem::Specification.new do |s|
  s.name        = 'knife-inspect'
  s.version     = HealthInspector::VERSION
  s.authors     = ['Greg Karékinian', 'Ben Marini']
  s.email       = ['greg@karekinian.com']
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/bmarini/knife-inspect'
  s.summary     = 'Inspect your chef repo as it is compared to what is on your chef server'
  s.description = 'knife-inspect is a knife plugin to compare the content of your Chef repository and Chef server'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency 'rake',      '~> 10.1'
  s.add_development_dependency 'rspec',     '~> 3.4.0'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'coveralls', '~> 0.7'

  s.add_runtime_dependency 'chef',      chef_version
  s.add_runtime_dependency 'rack',      '< 2'
  s.add_runtime_dependency 'parallel',  '~> 1.3'
  s.add_runtime_dependency 'inflecto',  '~> 0.0.2'
end
