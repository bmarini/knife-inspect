require "thor"

module HealthInspector
  class CLI < Thor
    class_option 'repopath', :type => :string, :aliases => "-r",
      :default => ".",
      :banner => "Path to your local chef-repo"

    class_option 'configpath', :type => :string, :aliases => "-c",
      :default => ".chef/knife.rb",
      :banner => "Path to your knife config file."

    desc "inspect", "Inspect a chef server repo"
    def inspect
      Inspector.inspect(options[:repopath], options[:configpath])
    end
  end
end