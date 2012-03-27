require "chef/config"

module HealthInspector
  class Context < Struct.new(:repo_path, :config_path)
    def knife_command(subcommnad)
      `cd #{repo_path} && knife #{subcommnad} -c #{config_path}`
    end

    def cookbook_path
      Array( config.cookbook_path )
    end

    def config
      @config ||= begin
        Chef::Config.from_file(config_path)
        Chef::Config
      end
    end
  end
end