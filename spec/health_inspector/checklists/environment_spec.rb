require 'spec_helper'

RSpec.describe HealthInspector::Checklists::Environment do
  let(:pairing) { described_class.new(health_inspector_context) }

  it_behaves_like 'a chef model'
  it_behaves_like 'a chef model that can be represented in json'

  it 'ignores _default environment if it only exists on server' do
    pairing.name   = '_default'
    pairing.server = {}
    pairing.local  = nil
    pairing.validate

    expect(pairing.errors).to be_empty
  end
end
