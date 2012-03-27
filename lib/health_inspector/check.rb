module HealthInspector
  module Check
    def run_check
      check
      return failure
    end

    def failure(message=nil)
      if message
        @failure = message
      else
        @failure
      end
    end
  end
end