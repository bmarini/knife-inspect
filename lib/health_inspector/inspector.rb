module HealthInspector
  class Inspector
    def self.inspect(repo_path, config_path)
      new(repo_path, config_path).inspect
    end

    def initialize(repo_path, config_path)
      @context = Context.new( repo_path, File.join(repo_path, config_path) )
    end

    def inspect
      Checklists::Cookbooks.run(@context)
    end
  end
end
