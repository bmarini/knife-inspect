require 'spec_helper'
require 'chef/knife/data_bag_inspect'

RSpec.describe Chef::Knife::DataBagInspect do
  describe '#run' do
    context 'when not passing arguments' do
      let :data_bag_inspect do
        described_class.new
      end

      it 'inspects all the data bags and data bag items' do
        expect(HealthInspector::Checklists::DataBags).to receive(:run)
          .with(data_bag_inspect)
          .and_return true
        expect(HealthInspector::Checklists::DataBagItems).to receive(:run)
          .with(data_bag_inspect)
          .and_return true
        expect(data_bag_inspect).to receive(:exit).with true

        data_bag_inspect.run
      end
    end

    context 'when passing a data_bag as an argument' do
      let :data_bag_inspect do
        described_class.new ['some_data_bag']
      end

      let :checklist do
        double
      end

      let :data_bag do
        double
      end

      it 'inspects this data_bag' do
        expect(HealthInspector::Checklists::DataBags).to receive(:new)
          .with(data_bag_inspect)
          .and_return checklist
        expect(checklist).to receive(:load_item)
          .with('some_data_bag').and_return data_bag
        expect(checklist).to receive(:validate_item)
          .with(data_bag).and_return true
        expect(data_bag_inspect).to receive(:exit).with true

        data_bag_inspect.run
      end
    end

    context 'when passing a data bag and data_bag item as arguments' do
      let :data_bag_inspect do
        described_class.new ['some_data_bag', 'item']
      end

      let :checklist do
        double
      end

      let :data_bag do
        double
      end

      it 'inspects this data_bag' do
        expect(HealthInspector::Checklists::DataBagItems).to receive(:new)
          .with(data_bag_inspect)
          .and_return checklist
        expect(checklist).to receive(:load_item)
          .with('some_data_bag/item')
          .and_return data_bag
        expect(checklist).to receive(:validate_item)
          .with(data_bag).and_return true
        expect(data_bag_inspect).to receive(:exit).with true

        data_bag_inspect.run
      end
    end
  end
end
