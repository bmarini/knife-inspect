require 'spec_helper'

describe HealthInspector::Checklists::Cookbook do
  let(:pairing) { described_class.new(health_inspector_context, :name => "dummy") }

  it "should detect if an item does not exist locally" do
    pairing.server = "0.0.1"
    pairing.local  = nil
    pairing.validate

    pairing.errors.should_not be_empty
    pairing.errors.first.should == "exists on server but not locally"
  end

  it "should detect if an item does not exist on server" do
    pairing.server = nil
    pairing.local  = "0.0.1"
    pairing.validate

    pairing.errors.should_not be_empty
    pairing.errors.first.should == "exists locally but not on server"
  end

  it "should detect if an item is different" do
    pairing.server = "0.0.1"
    pairing.local  = "0.0.2"
    pairing.validate

    pairing.errors.should_not be_empty
    pairing.errors.first.should == "chef server has 0.0.1 but local version is 0.0.2"
  end

  it "should detect if an item is the same" do
    pairing.should_receive(:validate_changes_on_the_server_not_in_the_repo)
    pairing.server = "0.0.1"
    pairing.local  = "0.0.1"
    pairing.validate

    pairing.errors.should be_empty
  end
end