require 'spec_helper'
require 'chef/knife/inspect'

RSpec.describe Chef::Knife::Inspect do
  let :knife_inspect do
    described_class.new
  end

  it 'inherits from Chef::Knife' do
    expect(knife_inspect).to be_a Chef::Knife
  end

  describe '#run' do
    subject do
      knife_inspect.run
    end

    context 'when all the checklists pass' do
      it 'runs all the check lists and exits with 0' do
        { HealthInspector::Checklists::Cookbooks => true,
          HealthInspector::Checklists::DataBags => true,
          HealthInspector::Checklists::DataBagItems => true,
          HealthInspector::Checklists::Environments => true,
          HealthInspector::Checklists::Roles => true }.each do |checklist, status|
          expect(checklist).to receive(:run).and_return status
        end

        expect(knife_inspect).to receive(:exit).with true

        subject
      end
    end

    context 'when one or more checklists fail' do
      it 'runs all the check lists and exits with 1' do
        { HealthInspector::Checklists::Cookbooks => true,
          HealthInspector::Checklists::DataBags => false,
          HealthInspector::Checklists::DataBagItems => true,
          HealthInspector::Checklists::Environments => true,
          HealthInspector::Checklists::Roles => true }.each do |checklist, status|
          expect(checklist).to receive(:run).and_return status
        end

        expect(knife_inspect).to receive(:exit).with false

        subject
      end
    end
  end

end
