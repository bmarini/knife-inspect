module HealthInspector
  class Inspector
    def self.inspect(checklists, repo_path, config_path)
      new(repo_path, config_path).inspect( checklists )
    end

    def initialize(repo_path, config_path)
      @context = Context.new( repo_path, config_path )
      @context.configure
    end

    def inspect(checklists)
      checklists.each do |checklist|
        Checklists.const_get(checklist).run(@context) if Checklists.const_defined?(checklist)
      end
    end
  end
end
