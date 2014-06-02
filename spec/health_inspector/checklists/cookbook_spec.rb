require 'spec_helper'

RSpec.describe HealthInspector::Checklists::Cookbook do
  let(:pairing) do
    described_class.new(health_inspector_context, :name => 'dummy')
  end

  it 'detects if an item does not exist locally' do
    pairing.server = '0.0.1'
    pairing.local  = nil
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('exists on server but not locally')
  end

  it 'detects if an item does not exist on server' do
    pairing.server = nil
    pairing.local  = '0.0.1'
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('exists locally but not on server')
  end

  it 'detects if an item is different' do
    pairing.server = '0.0.1'
    pairing.local  = '0.0.2'
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('chef server has 0.0.1 but local version is 0.0.2')
  end

  it 'detects if an item is the same' do
    expect(pairing).to receive(:validate_changes_on_the_server_not_in_the_repo)
    pairing.server = '0.0.1'
    pairing.local  = '0.0.1'
    pairing.validate

    expect(pairing.errors).to be_empty
  end
end
