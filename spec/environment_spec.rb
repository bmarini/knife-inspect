require 'spec_helper'

describe HealthInspector::Checklists::Environment do
  let(:pairing) { described_class.new(health_inspector_context) }

  it_behaves_like "a chef model"
  it_behaves_like "a chef model that can be respresented in json"

  it "should ignore _default environment if it only exists on server" do
    pairing.name   = "_default"
    pairing.server = {}
    pairing.local  = nil
    pairing.validate

    pairing.errors.should be_empty
  end

end
