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

      CHECKLISTS.map do |checklist|
        opt_name = checklist.downcase.to_sym
        option opt_name,
          :long => "--[no-]#{opt_name}",
          :boolean => true,
          :default => true,
          :description => "Add or exclude #{opt_name} from inspection"
      end

      def run
        results = CHECKLISTS.select do |checklist|
          opt_name = checklist.downcase.to_sym
          config[opt_name] or config[opt_name].nil?
        end.map do |checklist|
          HealthInspector::Checklists.const_get(checklist).run(self)
        end

        exit !results.include?(false)
      end
    end
  end
end
