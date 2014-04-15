require 'spec_helper'

describe HealthInspector::Checklists::Environments do
  let :checklist do
    described_class.new(nil)
  end

  before do
    expect(HealthInspector::Context).to receive(:new).with(nil)
      .and_return health_inspector_context
  end

  describe '#server_items' do
    let :environments do
      { 'environment_one'         => 'url',
        'environment_two'         => 'url',
        'environment_from_subdir' => 'url' }
    end

    it 'returns a list of environments from the chef server' do
      expect(Chef::Environment).to receive(:list).and_return environments
      expect(checklist.server_items.sort)
        .to eq %w(environment_from_subdir environment_one environment_two)
    end
  end

  describe '#local_items' do
    it 'returns a list of environments from the chef repo' do
      expect(checklist.local_items.sort)
        .to eq %w(environment_from_subdir environment_one environment_two)
    end
  end
end
