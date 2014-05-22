require 'spec_helper'

RSpec.describe HealthInspector::Checklists::DataBagItems do
  let :checklist do
    described_class.new(nil)
  end

  before do
    expect(HealthInspector::Context).to receive(:new).with(nil)
      .and_return health_inspector_context
  end

  describe '#server_items' do
    it 'returns a list of data bag items from the chef server' do
      expect(Chef::DataBag).to receive(:list).and_return(
        'data_bag_one'         => 'url',
        'data_bag_two'         => 'url',
        'data_bag_from_subdir' => 'url'
      )
      { 'data_bag_one' => 'one',
        'data_bag_two' => 'two',
        'data_bag_from_subdir' => 'three' }.each do |data_bag, item|
          expect(Chef::DataBag).to receive(:load).with(data_bag)
            .and_return item => 'url'
        end
      expect(checklist.server_items.sort)
        .to eq %w(data_bag_from_subdir/three data_bag_one/one data_bag_two/two)
    end
  end

  describe '#local_items' do
    it 'returns a list of data bag items from the chef repo' do
      expect(checklist.local_items.sort).to eq [
        'data_bag_from_subdir/three', 'data_bag_one/one', 'data_bag_two/two'
      ]
    end
  end

  describe '#load_item(name)' do
    let :name do
      'data_bag_one/one'
    end

    let :item do
      checklist.load_item name
    end

    it 'instanciates a DataBagItem pairing for that item' do
      expect(checklist).to receive(:load_item_from_local)
        .with(name).and_return name
      expect(checklist).to receive(:load_item_from_server)
        .with(name).and_return name

      expect(item).to be_a(HealthInspector::Checklists::DataBagItem)
      expect(item.name).to eq(name)
      expect(item.server).to eq(name)
    end
  end

  describe '#load_item_from_local(name)' do
    context 'when the data bag item exists' do
      let :name do
        'data_bag_one/one'
      end

      it 'returns a parsed version of the data bag item' do
        expect(checklist.load_item_from_local(name))
          .to eq('id' => 'one', 'some' => 'key')
      end
    end

    context 'when the data bag item does not exist' do
      let :name do
        'data_bag_one/non_existent'
      end

      it 'returns nil' do
        expect(checklist.load_item_from_local(name)).to be_nil
      end
    end

    context 'when the data bag item is not valid json' do
      let :name do
        'data_bag_two/two'
      end

      it 'returns nil' do
        expect(checklist.load_item_from_local(name)).to be_nil
      end
    end
  end

  describe '#load_item_from_server(name)' do
    context 'when the data bag item exists' do
      let :name do
        'data_bag_one/one'
      end

      let :data_bag_item do
        double(:raw_data => { 'id' => 'one', 'some' => 'key' })
      end

      it 'returns a parsed version of the data bag item' do
        expect(Chef::DataBagItem).to receive(:load).with('data_bag_one', 'one')
          .and_return(data_bag_item)
        expect(checklist.load_item_from_server(name))
          .to eq('id' => 'one', 'some' => 'key')
      end
    end

    context 'when the data bag item does not exist' do
      let :name do
        'data_bag_one/non_existent'
      end

      it 'returns nil' do
        expect(Chef::DataBagItem).to receive(:load)
          .with('data_bag_one', 'non_existent')
          .and_raise(Net::HTTPServerException.new('404 "Object Not Found"',
                                                  'response'))
        expect(checklist.load_item_from_server(name)).to be_nil
      end
    end
  end
end
