require "chef/config"

module HealthInspector
  class Context
    attr_accessor :knife

    def initialize(knife)
      @knife = knife
    end

    def cookbook_path
      Array(config.cookbook_path)
    end

    def config
      Chef::Config
    end

    def rest
      @knife.rest
    end

    def repo_path
      ENV['PWD']
    end
  end
end
