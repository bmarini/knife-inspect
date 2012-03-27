module HealthInspector
  module Check
    def failure(message=nil)
      if message
        @failure = message
      else
        @failure
      end
    end
  end
end