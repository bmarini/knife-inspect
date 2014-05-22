require 'spec_helper'

RSpec.describe HealthInspector::Checklists::Cookbooks do
  let :checklist do
    described_class.new(nil)
  end

  before do
    expect(HealthInspector::Context).to receive(:new).with(nil)
      .and_return health_inspector_context
  end

  describe '#server_items' do
    it 'returns a list of roles from the chef server' do
      allow(health_inspector_context).to receive(:rest).and_return(double)
      expect(health_inspector_context.rest).to receive(:get_rest)
        .with('/cookbooks')
        .and_return(
          'cookbook_one' => { 'versions' => [{ 'version' => '1.0.0' }] },
          'cookbook_two' => { 'versions' => [{ 'version' => '0.0.1' }] }
      )
      expect(checklist.server_items).to eq(
        'cookbook_one' => Chef::Version.new('1.0.0'),
        'cookbook_two' => Chef::Version.new('0.0.1')
      )
    end
  end

  describe '#local_items' do
    it 'returns a list of roles from the chef repo' do
      expect(checklist.local_items).to eq(
        'cookbook_one' => Chef::Version.new('1.0.0'),
        'cookbook_two' => Chef::Version.new('0.0.1')
      )
    end
  end
end
