require 'chef/knife'
require 'health_inspector'

class Chef
  class Knife
    class CookbookInspect < Knife
      include HealthInspector::Runner

      checklist HealthInspector::Checklists::Cookbooks
      banner 'knife cookbook inspect [COOKBOOK] (options)'
    end
  end
end
