require 'chef/knife'

class Chef
  class Knife
    class Inspect < Knife

      deps do
        require "health_inspector"
      end

      banner "knife inspect"

      def run
        %w[ Cookbooks DataBags DataBagItems Environments Roles ].each do |checklist|
          HealthInspector::Checklists.const_get(checklist).run(self)
        end
      end
    end
  end
end
