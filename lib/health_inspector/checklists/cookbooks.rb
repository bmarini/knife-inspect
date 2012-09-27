module HealthInspector
  module Checklists

    class Cookbooks < Base

      add_check "local copy exists" do
        failure( "exists on chef server but not locally" ) if item.path.nil?
      end

      add_check "server copy exists" do
        failure( "exists locally but not on chef server" ) if item.server_version.nil?
      end

      add_check "versions" do
        if item.local_version && item.server_version &&
          item.local_version != item.server_version
          failure "chef server has #{item.server_version} but local version is #{item.local_version}"
        end
      end

      add_check "uncommitted changes" do
        if item.git_repo?
          result = `cd #{item.path} && git status -s`

          unless result.empty?
            failure "Uncommitted changes:\n#{result.chomp}"
          end
        end
      end

      add_check "commits not pushed to remote" do
        if item.git_repo?
          result = `cd #{item.path} && git status`

          if result =~ /Your branch is ahead of (.+)/
            failure "ahead of #{$1}"
          end
        end
      end

      add_check "changes on the server not in the repo" do
        if item.server_version == item.local_version &&
           !item.bad_files.empty? 
          fail_message = "has a checksum mismatch between server and repo in\n"
          fail_message << item.bad_files.map{|f| "    " + f + "\n"}.join.chop
          failure fail_message 
        end
      end

      class Cookbook < Struct.new(:name, :path, :server_version, :local_version, :bad_files)
        def git_repo?
          self.path && File.exist?("#{self.path}/.git")
        end
      end

      title "cookbooks"

      def items
        server_cookbooks           = cookbooks_on_server
        local_cookbooks            = cookbooks_in_repo
        all_cookbook_names = ( server_cookbooks.keys + local_cookbooks.keys ).uniq.sort

        all_cookbook_names.map do |name|
          Cookbook.new.tap do |cookbook|
            cookbook.name           = name
            cookbook.path           = cookbook_path(name)
            cookbook.server_version = server_cookbooks[name]
            cookbook.local_version  = local_cookbooks[name]
            cookbook.bad_files      = checksum_compare(name, cookbook.server_version)
          end
        end
      end

      def cookbooks_on_server
        Yajl::Parser.parse( @context.knife_command("cookbook list -Fj") ).inject({}) do |hsh, c|
          name, version = c.split
          hsh[name] = version
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

            hsh[name] = version
            hsh
          end
      end

      def cookbook_path(name)
        path = @context.cookbook_path.find { |f| File.exist?("#{f}/#{name}") }
        path ? File.join(path, name) : nil
      end

      def checksum_compare(name,version)
        begin
          cookbook = chef_rest.get_rest("/cookbooks/#{name}/#{version}")
        rescue Net::HTTPServerException => e
          return ["Could not find cookbook #{name} on the server"]
        end

        cookbook.manifest.inject([]) do |memo, (key,value)|
          if value.kind_of? Array
            value.each do |file|
              path = cookbook_path("#{name}/#{file["path"]}")
              if path
                checksum = Chef::ChecksumCache.generate_md5_checksum_for_file(path)
                memo << "#{file['path']}" if checksum != file['checksum']
              else
                memo << "#{file['path']} does not exist in the repo"
              end
            end
          end
          memo
        end
      end

    end
  end
end
