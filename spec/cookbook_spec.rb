require 'spec_helper'

describe "HealthInspector::Checklists::Cookbooks" do
  subject do
    HealthInspector::Checklists::Cookbooks.new(health_inspector_context)
  end

  # :name, :path, :server_version, :local_version, :bad_files
  let(:item) { HealthInspector::Checklists::Cookbooks::Cookbook }

  it "should detect if a cookbook does not exist locally" do
    obj = item.new("ruby", nil, "0.0.1", nil, [])

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists on server but not locally"
  end

  it "should detect if a cookbook does not exist on server" do
    obj = item.new("ruby", "cookbooks/ruby", nil, "0.0.1", [])

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists locally but not on server"
  end
end