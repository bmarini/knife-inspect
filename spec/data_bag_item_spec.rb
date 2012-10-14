require 'spec_helper'

describe "HealthInspector::Checklists::DataBagItems" do
  subject do
    HealthInspector::Checklists::DataBagItems.new(health_inspector_context)
  end

  let(:item) { HealthInspector::Checklists::DataBagItems::DataBagItem }

  it "should detect if a data bag item does not exist locally" do
    obj = item.new("apps", {"foo" => "bar"}, nil)

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists on server but not locally"
  end

  it "should detect if a data bag item does not exist on server" do
    obj = item.new("apps", nil, {"foo" => "bar"})

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists locally but not on server"
  end

  it "should detect if a data bag item is different" do
    obj = item.new("apps", {"foo" => "bar"}, {"foo" => "baz"})

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == {"foo" => {"server" => "bar", "local" => "baz"}}
  end

  it "should detect if a data bag item is the same" do
    obj = item.new("apps", {"foo" => "bar"}, {"foo" => "bar"})

    failures = subject.run_checks(obj)
    failures.should be_empty
  end
end