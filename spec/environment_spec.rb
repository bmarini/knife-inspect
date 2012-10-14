require 'spec_helper'

describe "HealthInspector::Checklists::Environments" do
  subject do
    HealthInspector::Checklists::Environments.new(health_inspector_context)
  end

  let(:item) { HealthInspector::Checklists::Environments::Environment }

  it "should detect if an environment does not exist locally" do
    obj = item.new("production", {}, nil)

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists on server but not locally"
  end

  it "should detect if an environment does not exist on server" do
    obj = item.new("production", nil, {})

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists locally but not on server"
  end

  it "should detect if an environment is different" do
    obj = item.new("production", {"foo" => "bar"}, {"foo" => "baz"})

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == {"foo"=>{"server"=>"bar", "local"=>"baz"}}
  end

  it "should detect if an environment is the same" do
    obj = item.new("production", {}, {})

    failures = subject.run_checks(obj)
    failures.should be_empty
  end

end