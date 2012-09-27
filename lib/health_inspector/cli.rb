require "thor"

module HealthInspector
  class CLI < Thor
    class_option 'repopath', :type => :string, :aliases => "-r",
      :default => ".",
      :banner => "Path to your local chef-repo"

    class_option 'configpath', :type => :string, :aliases => "-c",
      :default => ".chef/knife.rb",
      :banner => "Path to your knife config file."

    desc "inspect [COMPONENT]", "Inspect a chef repo. Optionally, specify an individual chef component to inspect. One of cookbooks, databags, databagitems, environments, roles"
    def inspect(component='')
      Inspector.inspect(component,options[:repopath], options[:configpath])
    end
  end
end
