require "chef/config"

module HealthInspector
  class Context < Struct.new(:repo_path, :config_path)
    def cookbook_path
      Array( config.cookbook_path )
    end

    def config
      @config ||= configure
    end

    def configure
      Chef::Config.from_file(config_path)
      Chef::Config
    end
  end
end
