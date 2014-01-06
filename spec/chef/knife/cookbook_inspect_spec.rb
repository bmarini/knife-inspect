require 'spec_helper'
require 'chef/knife/cookbook_inspect'

describe Chef::Knife::CookbookInspect do
  it_behaves_like 'a knife inspect runner' do
    let :checklist do
      HealthInspector::Checklists::Cookbooks
    end
  end
end
