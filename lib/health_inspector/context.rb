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
      @config ||= configure
    end

    def configure
      Chef::Config.from_file(config_path)
      Chef::Config
    end

    def chef_rest
      @chef_rest ||= Chef::REST.new( config[:chef_server_url], config[:node_name], config[:client_key] )
    end
  end
end