require 'chef/knife'

class Chef
  class Knife
    class EnvironmentInspect < Knife

      deps do
        require 'health_inspector'
      end

      banner "knife environment inspect [ENVIRONMENT] (options)"

      def run
        case @name_args.length
        when 1 # We are inspecting a environment
          environment_name = @name_args[0]
          validator = HealthInspector::Checklists::Environments.new(self)
          validator.validate_item( validator.load_item(environment_name) )
        when 0 # We are inspecting all the environments
          HealthInspector::Checklists::Environments.run(self)
        end
      end
    end
  end
end
