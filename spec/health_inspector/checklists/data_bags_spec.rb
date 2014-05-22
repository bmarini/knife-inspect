require 'spec_helper'

RSpec.describe HealthInspector::Checklists::DataBags do
  let :checklist do
    described_class.new(nil)
  end

  before do
    expect(HealthInspector::Context).to receive(:new).with(nil)
      .and_return health_inspector_context
  end

  describe '#server_items' do
    it 'returns a list of data bags from the chef server' do
      expect(Chef::DataBag).to receive(:list).and_return(
        'data_bag_one'         => 'url',
        'data_bag_two'         => 'url',
        'data_bag_from_subdir' => 'url'
      )
      expect(checklist.server_items.sort)
        .to eq %w(data_bag_from_subdir data_bag_one data_bag_two)
    end
  end

  describe '#local_items' do
    it 'returns a list of data bags from the chef repo' do
      expect(checklist.local_items.sort)
        .to eq %w(data_bag_from_subdir data_bag_one data_bag_two)
    end
  end

  describe '#load_item(name)' do
    let :name do
      'data bag'
    end

    let :item do
      checklist.load_item name
    end

    it 'instanciates a DataBag pairing for that item' do
      expect(checklist).to receive(:server_items).and_return ['data bag']
      expect(checklist).to receive(:local_items).and_return ['data bag']
      expect(item).to be_a(HealthInspector::Checklists::DataBag)
      expect(item.name).to eq(name)
      expect(item.server).to eq(true)
      expect(item.local).to eq(true)
    end
  end
end
