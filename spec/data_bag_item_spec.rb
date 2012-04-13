require 'spec_helper'

describe "HealthInspector::Checklists::DataBagItems" do
  subject do
    HealthInspector::Checklists::DataBagItems.new(health_inspector_context)
  end

  it "should detect if a data bag item does not exist locally" do
    subject.expects(:data_bag_items_on_server).returns( ["apps/app1"] )
    subject.expects(:load_item_from_server).with("apps/app1").returns({})
    failures = subject.run_checks(subject.items.first)
    failures.first.include?("exists on server but not locally").must_equal true
  end
end