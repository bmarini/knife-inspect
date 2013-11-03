require 'chef/knife'

class Chef
  class Knife
    class CookbookInspect < Knife

      deps do
        require 'health_inspector'
        require 'chef/json_compat'
        require 'uri'
        require 'chef/cookbook_version'
      end

      banner "knife cookbook inspect [COOKBOOK] (options)"

      def run
        case @name_args.length
        when 1 # We are inspecting a cookbook
          cookbook_name = @name_args[0]
          # TODO: Support environments
          # env           = config[:environment]
          # api_endpoint  = env ? "environments/#{env}/cookbooks/#{cookbook_name}" : "cookbooks/#{cookbook_name}"

          validator = HealthInspector::Checklists::Cookbooks.new(self)
          exit validator.validate_item( validator.load_item(cookbook_name) )
        when 0 # We are inspecting all the cookbooks
          exit HealthInspector::Checklists::Cookbooks.run(self)
        end
      end
    end
  end
end




