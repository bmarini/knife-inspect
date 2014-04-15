require 'chef/knife'
require 'health_inspector'

class Chef
  class Knife
    class EnvironmentInspect < Knife
      include HealthInspector::Runner

      checklist HealthInspector::Checklists::Environments
      banner 'knife environment inspect [ENVIRONMENT] (options)'
    end
  end
end
