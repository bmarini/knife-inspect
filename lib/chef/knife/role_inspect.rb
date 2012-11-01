require 'chef/knife'

class Chef
  class Knife
    class RoleInspect < Knife

      deps do
        require 'health_inspector'
      end

      banner "knife role inspect [ROLE] (options)"

      def run 
        case @name_args.length
        when 1 # We are inspecting a role
          role_name = @name_args[0]
          validator = HealthInspector::Checklists::Roles.new(self)
          validator.validate_item( validator.load_item(role_name) )
        when 0 # We are inspecting all the roles
          HealthInspector::Checklists::Roles.run(self)
        end
      end
    end
  end
end
