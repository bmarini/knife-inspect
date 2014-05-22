require 'spec_helper'

RSpec.describe HealthInspector::Checklists::Roles do
  let :checklist do
    described_class.new(nil)
  end

  before do
    expect(HealthInspector::Context).to receive(:new).with(nil)
      .and_return health_inspector_context
  end

  describe '#server_items' do
    it 'returns a list of roles from the chef server' do
      expect(Chef::Role).to receive(:list).and_return(
        'role_one'         => 'url',
        'role_two'         => 'url',
        'role_from_subdir' => 'url'
      )
      expect(checklist.server_items.sort)
        .to eq %w(role_from_subdir role_one role_two)
    end
  end

  describe '#local_items' do
    it 'returns a list of roles from the chef repo' do
      expect(checklist.local_items.sort)
        .to eq %w(role_from_subdir role_one role_two)
    end
  end
end
