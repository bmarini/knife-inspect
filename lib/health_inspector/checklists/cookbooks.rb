require 'chef/version'
require 'chef/cookbook_version'
require 'chef/cookbook_loader'
require 'chef/checksum_cache' if Gem::Version.new(Chef::VERSION) < Gem::Version.new('11.0.0')

module HealthInspector
  module Checklists
    class Cookbook < Pairing
      include ExistenceValidations

      def validate_versions
        Chef::Log.debug("#{name}: Validating versions")

        if versions_exist? && !versions_match?
          errors.add "chef server has #{server} but local version is #{local}"
        end
      end

      def validate_uncommited_changes
        Chef::Log.debug("#{name}: Validating uncommited changes")
        return unless git_repo?

        result = `cd #{cookbook_path} && git status -s`

        errors.add "Uncommitted changes:\n#{result.chomp}" unless result.empty?
      end

      def validate_commits_not_pushed_to_remote
        Chef::Log.debug("#{name}: Validating commits not pushed to remote")
        return unless git_repo?

        result = `cd #{cookbook_path} && git status`

        if result =~ /Your branch is ahead of (.+)/
          errors.add "ahead of #{Regexp.last_match[1]}"
        end
      end

      # TODO: Check files that exist locally but not in manifest on server
      def validate_changes_on_the_server_not_in_the_repo
        Chef::Log.debug("#{name}: Validating changes on the server not in the repo")

        return unless versions_exist? && versions_match?
        return if cookbook_path.nil?

        begin
          messages = []

          Chef::CookbookVersion::COOKBOOK_SEGMENTS.each do |segment|
            remote_cookbook.manifest[segment].each do |manifest_record|
              path = cookbook_path.join("#{manifest_record['path']}")
              Chef::Log.debug("#{name}: Checking remote file #{manifest_record['path']}")
              next if path.basename.to_s == '.git'

              if path.exist?
                checksum = Chef::CookbookVersion.checksum_cookbook_file(path)
                messages << "#{manifest_record['path']}" if checksum != manifest_record['checksum']
              else
                messages << "#{manifest_record['path']} does not exist in the repo"
              end
            end
          end

          unless messages.empty?
            message = "has a checksum mismatch between server and repo in\n"
            message << messages.map { |f| "    #{f}" }.join("\n")
            errors.add message
          end

        rescue Net::HTTPServerException
          errors.add "Could not find cookbook #{name} on the server"
        end
      end

      def remote_files
        return [] if remote_cookbook.nil?

        @remote_files ||=
          begin
            remote_cookbook.manifest_records_by_path.keys
          end
      end

      def remote_cookbook
        @remote_cookbook ||=
          begin
            context.rest.get_rest("/cookbooks/#{name}/#{local}")
          rescue Net::HTTPServerException
            nil
          end
      end

      def versions_exist?
        local && server
      end

      def versions_match?
        local == server
      end

      def git_repo?
        cookbook_path && File.exist?("#{cookbook_path}/.git")
      end

      def cookbook_path
        @cookbook_path ||= begin
          path = context.cookbook_path.find { |f| File.exist?("#{f}/#{name}") }

          path ? Pathname.new(path).join(name) : nil
        end
      end
    end

    class Cookbooks < Base
      title 'cookbooks'

      def load_item(name)
        Cookbook.new(@context,
                     name: name,
                     server: server_items[name],
                     local: local_items[name])
      end

      def server_items
        @context.rest.get_rest('/cookbooks').reduce({}) do |hsh, (name, version)|
          hsh[name] = Chef::Version.new(version['versions'].first['version'])
          hsh
        end
      end

      def local_items
        cl = Chef::CookbookLoader.new(@context.cookbook_path)
        cl.load_cookbooks

        cl.inject({}) do |hash, (name, cookbook_version)|
          hash[name] = Chef::Version.new(cookbook_version.version)

          hash
        end
      end

      def all_item_names
        (server_items.keys + local_items.keys).uniq.sort
      end
    end
  end
end
