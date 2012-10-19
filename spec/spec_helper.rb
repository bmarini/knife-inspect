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

shared_examples "a chef model" do
  let(:pairing) { described_class.new(health_inspector_context, :name => "dummy") }

  it "should detect if an item does not exist locally" do
    pairing.server = {}
    pairing.local  = nil
    pairing.validate

    pairing.errors.should_not be_empty
    pairing.errors.first.should == "exists on server but not locally"
  end

  it "should detect if an item does not exist on server" do
    pairing.server = nil
    pairing.local  = {}
    pairing.validate

    pairing.errors.should_not be_empty
    pairing.errors.first.should == "exists locally but not on server"
  end
end

shared_examples "a chef model that can be respresented in json" do
  let(:pairing) { described_class.new(health_inspector_context, :name => "dummy") }

  it "should detect if an item is different" do
    pairing.server = {"foo" => "bar"}
    pairing.local  = {"foo" => "baz"}
    pairing.validate

    pairing.errors.should_not be_empty
    pairing.errors.first.should == {"foo"=>{"server"=>"bar", "local"=>"baz"}}
  end

  it "should detect if an item is the same" do
    pairing.server = {"foo" => "bar"}
    pairing.local  = {"foo" => "bar"}
    pairing.validate

    pairing.errors.should be_empty
  end
end