require 'spec_helper'

describe "HealthInspector::Checklists::DataBags" do
  subject do
    HealthInspector::Checklists::DataBags.new(health_inspector_context)
  end

  let(:item) { HealthInspector::Checklists::DataBags::DataBag }

  it "should detect if a data bag does not exist locally" do
    obj = item.new("users", true, false)

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists on server but not locally"
  end

  it "should detect if a data bag does not exist on server" do
    obj = item.new("users", false, true)

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists locally but not on server"
  end
end