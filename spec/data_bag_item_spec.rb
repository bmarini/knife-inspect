require 'spec_helper'

describe "HealthInspector::Checklists::DataBagItems" do
  subject do
    HealthInspector::Checklists::DataBagItems.new(health_inspector_context)
  end

  it "should detect if a data bag item does not exist locally" do
    item = HealthInspector::Checklists::DataBagItems::DataBagItem.new(
      :name => "apps", :server => ["apps/app1"], :local => nil
    )

    failures = subject.run_checks(item)
    failures.first.include?("exists on server but not locally").must_equal true
  end
end