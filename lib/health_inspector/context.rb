module HealthInspector
  class Context < Struct.new(:repo_path, :config_path)
    def knife_command(subcommnad)
      `cd #{repo_path} && knife #{subcommnad} -c #{config_path}`
    end

    # TODO: read from knife config
    def cookbook_path
      [ File.join(repo_path, "cookbooks") ]
    end
  end
end