require 'spec_helper'

describe HealthInspector::Checklists::DataBagItems do
  let :checklist do
    described_class.new(nil)
  end

  before do
    expect(HealthInspector::Context).to receive(:new).with(nil).
      and_return health_inspector_context
  end

  describe '#server_items' do
    it 'returns a list of data bag items from the chef server' do
      expect(Chef::DataBag).to receive(:list).and_return({
        'data_bag_one'         => 'url',
        'data_bag_two'         => 'url',
        'data_bag_from_subdir' => 'url'
      })
      { 'data_bag_one' => 'one',
        'data_bag_two' => 'two',
        'data_bag_from_subdir' => 'three' }.each do |data_bag, item|
        expect(Chef::DataBag).to receive(:load).with(data_bag).
          and_return({ item => 'url' })
        end
      expect(checklist.server_items.sort).to eq [
        'data_bag_from_subdir/three', 'data_bag_one/one', 'data_bag_two/two'
      ]
    end
  end

  describe '#local_items' do
    it 'returns a list of data bag items from the chef repo' do
      expect(checklist.local_items.sort).to eq [
        'data_bag_from_subdir/three', 'data_bag_one/one', 'data_bag_two/two'
      ]
    end
  end
end
