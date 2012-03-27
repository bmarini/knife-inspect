module HealthInspector
  module Checklists

    Cookbook = Struct.new(:name, :path, :server_version, :local_version)

    class CookbookCheck < Struct.new(:cookbook)
      include Check

      def run_check
        check
        return failure
      end
    end

    class CheckLocalCopyExists < CookbookCheck
      def check
        failure( "exists on chef server but not locally" ) if cookbook.path.nil?
      end
    end

    class CheckVersionsAreTheSame < CookbookCheck
      def check
        if cookbook.local_version && cookbook.server_version &&
           cookbook.local_version != cookbook.server_version
          failure "chef server has #{cookbook.server_version} but local version is #{cookbook.local_version}"
        end
      end
    end

    class CheckUncommittedChanges < CookbookCheck
      def check
        if cookbook.path && File.exist?("#{cookbook.path}/.git")
          result = `cd #{cookbook.path} && git status -s`

          unless result.empty?
            failure "Uncommitted changes:\n#{result.chomp}"
          end
        end
      end
    end

    class Cookbooks < Base
      def self.run(context)
        new(context).run
      end

      def initialize(context)
        @context = context
      end

      def run
        banner "Inspecting cookbooks"

        cookbooks.each do |cookbook|
          failures = cookbook_checks.map { |c| c.new(cookbook).run_check }.compact
          if failures.empty?
            print_success(cookbook.name)
          else
            print_failures(cookbook.name, failures)
          end
        end
      end

      def cookbooks
        server_cookbooks   = cookbooks_on_server
        local_cookbooks    = cookbooks_in_repo
        all_cookbook_names = ( server_cookbooks.keys + local_cookbooks.keys ).uniq.sort

        all_cookbook_names.map do |name|
          Cookbook.new.tap do |cookbook|
            cookbook.name           = name
            cookbook.path           = cookbook_path(name)
            cookbook.server_version = server_cookbooks[name]
            cookbook.local_version  = local_cookbooks[name]
          end
        end
      end

      def cookbooks_on_server
        JSON.parse( @context.knife_command("cookbook list -Fj") ).inject({}) do |hsh, c|
          name, version = c.split
          hsh[name] = version
          hsh
        end
      end

      def cookbooks_in_repo
        @context.cookbook_path.map { |path| Dir["#{path}/*"] }.flatten.inject({}) do |hsh, path|
          name    = File.basename(path)
          version = (`grep '^version' #{path}/metadata.rb`).split.last[1...-1]

          hsh[name] = version
          hsh
        end
      end

      def cookbook_path(name)
        path = @context.cookbook_path.find { |f| File.exist?("#{f}/#{name}") }
        path ? File.join(path, name) : nil
      end

      def cookbook_checks
        [ CheckLocalCopyExists, CheckVersionsAreTheSame, CheckUncommittedChanges ]
      end
    end
  end
end
