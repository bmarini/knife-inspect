require 'chef/knife'

class Chef
  class Knife
    class Inspect < Knife
      CHECKLISTS = %w(Cookbooks DataBags DataBagItems Environments Roles)

      # :nocov:
      deps do
        require 'health_inspector'
      end
      # :nocov:

      banner 'knife inspect'

      CHECKLISTS.each do |checklist|
        checklist = ::HealthInspector::Checklists.const_get(checklist)

        option checklist.option,
          :long => "--[no-]#{checklist.option}",
          :boolean => true,
          :default => true,
          :description => "Add or exclude #{checklist.title} from inspection"
      end

      def run
        results = checklists_to_run.map do |checklist|
          ::HealthInspector::Checklists.const_get(checklist).run(self)
        end

        exit !results.include?(false)
      end

      private

      def checklists_to_run
        CHECKLISTS.select do |checklist|
          checklist = ::HealthInspector::Checklists.const_get(checklist)

          config[checklist.option]
        end
      end
    end
  end
end
