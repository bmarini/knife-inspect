require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'health_inspector'

module HealthInspector::SpecHelpers
  def health_inspector_context
    @health_inspector_context ||= begin
      repo_path = File.expand_path("../chef-repo", __FILE__)

      HealthInspector::Context.new( repo_path, File.join(repo_path, ".chef/knife.rb") ).tap do |context|
        context.configure
      end
    end
  end
end

class MiniTest::Unit::TestCase
  include HealthInspector::SpecHelpers
end