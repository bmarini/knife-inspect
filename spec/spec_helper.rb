if RUBY_VERSION > '1.9'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end

  require 'coveralls'
  Coveralls.wear!
end

require 'rubygems'
require 'bundler/setup'
require 'health_inspector'

module HealthInspector::SpecHelpers
  def health_inspector_context
    @health_inspector_context ||= HealthInspector::Context.new(nil)
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

  it "should detect if an item does not exist locally or on server" do
    pairing.server = nil
    pairing.local  = nil
    pairing.validate

    pairing.errors.to_a.should == ["does not exist locally or on server"]
  end
end

shared_examples "a chef model that can be represented in json" do
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

  it "should detect if an string and symbol keys convert to the same values" do
    pairing.server = {"foo" => "bar"}
    pairing.local  = {:foo => "bar"}
    pairing.validate

    pairing.errors.should be_empty
  end

  it "should detect if matching hashes are the same" do
    pairing.server = {"foo" => {"bar" => "fizz"}}
    pairing.local  = {"foo" => {"bar" => "fizz"}}
    pairing.validate

    pairing.errors.should be_empty
  end

  it "should detect if matching hashes with mismatched symbols and keys are the same" do
    pairing.server = {"foo" => {"bar" => "fizz"}}
    pairing.local  = {:foo => {:bar => "fizz"}}
    pairing.validate

    pairing.errors.should be_empty
  end

  it "should detect if matching arrays are the same" do
    pairing.server = {"foo" => ["bar", "fizz"]}
    pairing.local  = {"foo" => ["bar", "fizz"]}
    pairing.validate

    pairing.errors.should be_empty
  end

  it "should detect if matching arrays with hashes are the same" do
    pairing.server = {"foo" => ["bar", {"fizz" => "buzz"}]}
    pairing.local  = {"foo" => ["bar", {"fizz" => "buzz"}]}
    pairing.validate

    pairing.errors.should be_empty
  end

  it "should detect if matching arrays with hashes containing symbols/strings are the same" do
    pairing.server = {"foo" => ["bar", {"fizz" => "buzz"}]}
    pairing.local  = {"foo" => ["bar", {:fizz => "buzz"}]}
    pairing.validate

    pairing.errors.should be_empty
  end
end
