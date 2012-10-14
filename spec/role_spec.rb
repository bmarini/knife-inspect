require 'spec_helper'

describe "HealthInspector::Checklists::Roles" do
  subject do
    HealthInspector::Checklists::Roles.new(health_inspector_context)
  end

  let(:item) { HealthInspector::Checklists::Roles::Role }

  it "should detect if an role does not exist locally" do
    obj = item.new("app-server", {}, nil)

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists on server but not locally"
  end

  it "should detect if an role does not exist on server" do
    obj = item.new("app-server", nil, {})

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == "exists locally but not on server"
  end

  it "should detect if an role is different" do
    obj = item.new("app-server", {"foo" => "bar"}, {"foo" => "baz"})

    failures = subject.run_checks(obj)
    failures.should_not be_empty
    failures.first.should == {"foo"=>{"server"=>"bar", "local"=>"baz"}}
  end

  it "should detect if an role is the same" do
    obj = item.new("app-server", {}, {})

    failures = subject.run_checks(obj)
    failures.should be_empty
  end

end