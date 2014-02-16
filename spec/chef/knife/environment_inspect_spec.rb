require 'spec_helper'
require 'chef/knife/environment_inspect'

describe Chef::Knife::EnvironmentInspect do
  it_behaves_like 'a knife inspect runner' do
    let :checklist do
      HealthInspector::Checklists::Environments
    end
  end
end
