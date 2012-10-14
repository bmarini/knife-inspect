require 'rubygems'
require 'bundler/setup'
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

RSpec.configure do |c|
  c.include HealthInspector::SpecHelpers
end