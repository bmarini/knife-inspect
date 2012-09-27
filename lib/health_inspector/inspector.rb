module HealthInspector
  class Inspector
    def self.inspect(component,repo_path, config_path)
      new(repo_path, config_path).inspect(classify(component))
    end

    def self.classify(component)
      case component.downcase
      when "cookbooks"
        "Cookbooks"
      when "databags"
        "DataBags"
      when "databagitems"
        "DataBagItems"
      when "environments"
        "Environments"
      when "roles"
        "Roles"
      when "all"
        ''
      else
        puts "I did not understand which component you wanted me to inspect. Running all checks."
        ''
      end
    end

    def initialize(repo_path, config_path)
      @context = Context.new( repo_path, config_path )
      @context.configure
    end

    def inspect(component)
      if component.empty?
        Checklists::Cookbooks.run(@context)
        Checklists::DataBags.run(@context)
        Checklists::DataBagItems.run(@context)
        Checklists::Environments.run(@context)
        Checklists::Roles.run(@context)
      else
        Checklists.const_get(component).run(@context)
      end
    end
  end
end
