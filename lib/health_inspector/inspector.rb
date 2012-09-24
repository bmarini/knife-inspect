module HealthInspector
  class Inspector
    def self.inspect(repo_path, config_path)
      new(repo_path, config_path).inspect
    end

    def initialize(repo_path, config_path)
      @context = Context.new( repo_path, config_path )
      @context.configure
    end

    def inspect
      Checklists::Cookbooks.run(@context)
      Checklists::DataBags.run(@context)
      Checklists::DataBagItems.run(@context)
      Checklists::Environments.run(@context)
      Checklists::Roles.run(@context)
    end
  end
end
