module HealthInspector
  module Checklists

    class Cookbook < Pairing
      include ExistenceValidations

      def validate_versions
        if versions_exist? && !versions_match?
          errors.add "chef server has #{server} but local version is #{local}"
        end
      end

      def validate_uncommited_changes
        if git_repo?
          result = `cd #{cookbook_path} && git status -s`

          unless result.empty?
            errors.add "Uncommitted changes:\n#{result.chomp}"
          end
        end
      end

      def validate_commits_not_pushed_to_remote
        if git_repo?
          result = `cd #{cookbook_path} && git status`

          if result =~ /Your branch is ahead of (.+)/
            errors.add "ahead of #{$1}"
          end
        end
      end

      # TODO: Check files that exist locally but not in manifest on server
      def validate_changes_on_the_server_not_in_the_repo
        if versions_exist? && versions_match?

          begin
            cookbook = context.chef_rest.get_rest("/cookbooks/#{name}/#{local}")
            messages = []

            Chef::CookbookVersion::COOKBOOK_SEGMENTS.each do |segment|
              cookbook.manifest[segment].each do |manifest_record|
                path = cookbook_path.join("#{manifest_record["path"]}")

                if path.exist?
                  checksum = checksum_cookbook_file(path)
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

          rescue Net::HTTPServerException => e
            errors.add "Could not find cookbook #{name} on the server"
          end

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
        path = context.cookbook_path.find { |f| File.exist?("#{f}/#{name}") }
        path ? Pathname.new(path).join(name) : nil
      end

      def checksum_cookbook_file(filepath)
        Chef::CookbookVersion.checksum_cookbook_file(filepath)
      end

    end

    class Cookbooks < Base

      title "cookbooks"

      def each_item
        server_cookbooks   = cookbooks_on_server
        local_cookbooks    = cookbooks_in_repo
        all_cookbook_names = ( server_cookbooks.keys + local_cookbooks.keys ).uniq.sort

        all_cookbook_names.each do |name|
          item = Cookbook.new(@context,
            :name   => name,
            :server => server_cookbooks[name],
            :local  => local_cookbooks[name]
          )

          yield item
        end
      end

      def cookbooks_on_server
        chef_rest.get_rest("/cookbooks").inject({}) do |hsh, (name,version)|
          hsh[name] = Chef::Version.new(version["versions"].first["version"])
          hsh
        end
      end

      def cookbooks_in_repo
        @context.cookbook_path.
          map { |path| Dir["#{path}/*"] }.
          flatten.
          select { |path| File.exists?("#{path}/metadata.rb") }.
          inject({}) do |hsh, path|

            name    = File.basename(path)
            version = (`grep '^version' #{path}/metadata.rb`).split.last[1...-1]

            hsh[name] = Chef::Version.new(version)
            hsh
          end
      end

    end
  end
end
