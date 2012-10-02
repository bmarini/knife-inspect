require "thor"

module HealthInspector
  class CLI < Thor
    class_option 'repopath', :type => :string, :aliases => "-r",
      :default => ".",
      :banner => "Path to your local chef-repo."

    class_option 'configpath', :type => :string, :aliases => "-c",
      :default => ".chef/knife.rb",
      :banner => "Path to your knife config file."

    class_option 'no-color', :type => :boolean,
      :default => false,
      :banner => "Suppress output of ansi color messages."

    class_option 'quiet-success', :type => :boolean, :aliases => "-q",
      :default => false,
      :banner => "Suppress output of successful checks."

    default_task :inspect

    desc "inspect [COMPONENT]", <<-EOS
Inspect a chef repo. Optionally, specify one component to inspect:
[ cookbooks, databags, environments, roles ]
    EOS

    def inspect(component="")
      checklists = component_to_checklists(component)
      Inspector.inspect( checklists, options)
    end

    protected

    def component_to_checklists(component)
      all = %w[ Cookbooks DataBags DataBagItems Environments Roles ]

      case component.downcase
      when "cookbooks"
        ["Cookbooks"]
      when "databags"
        ["DataBags", "DataBagItems"]
      when "environments"
        ["Environments"]
      when "roles"
        ["Roles"]
      when "", "all"
        all
      else
        shell.say "I did not understand which component you wanted me to inspect. Running all checks."
        all
      end
    end

  end
end
