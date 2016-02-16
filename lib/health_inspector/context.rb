require 'chef/config'

module HealthInspector
  class Context
    attr_accessor :knife

    def initialize(knife)
      @knife = knife
    end

    def cookbook_path
      Array(Chef::Config.cookbook_path)
    end

    def repo_path
      ENV['PWD']
    end
  end
end
