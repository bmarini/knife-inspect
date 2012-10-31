require 'chef/knife'

class Chef
  class Knife
    class Inspect < Knife

      deps do
        require "health_inspector"
      end

      banner "knife inspect"

      def run
        @context        = HealthInspector::Context.new
        @context.config = Chef::Config

        %w[ Cookbooks DataBags DataBagItems Environments Roles ].each do |checklist|
          HealthInspector::Checklists.const_get(checklist).run(@context)
        end

      end
    end
  end
end
