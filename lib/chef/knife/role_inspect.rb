require 'chef/knife'
require 'health_inspector'

class Chef
  class Knife
    class RoleInspect < Knife
      include HealthInspector::Runner

      checklist HealthInspector::Checklists::Roles
      banner 'knife role inspect [ROLE] (options)'
    end
  end
end
