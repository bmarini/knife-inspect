module HealthInspector
  class Inspector
    def self.inspect(checklists, options)
      new(options).inspect( checklists )
    end

    def initialize(options)
      @context = Context.new( options[:repopath], options[:configpath] )
      @context.quiet_success = options[:'quiet-success']
      @context.no_color      = options[:'no-color']
      @context.configure
    end

    def inspect(checklists)
      checklists.each do |checklist|
        Checklists.const_get(checklist).run(@context) if Checklists.const_defined?(checklist)
      end
    end
  end
end
