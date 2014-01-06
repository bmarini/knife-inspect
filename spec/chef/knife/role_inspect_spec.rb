require 'spec_helper'
require 'chef/knife/role_inspect'

describe Chef::Knife::RoleInspect do
  it_behaves_like 'a knife inspect runner' do
    let :checklist do
      HealthInspector::Checklists::Roles
    end
  end
end
