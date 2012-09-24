require "chef/role"

module HealthInspector
  module Checklists
    class Roles < Base
      title "roles"

      require 'yajl'

      add_check "local copy exists" do
        failure "exists on server but not locally" unless item.local
      end

      add_check "server copy exists" do
        failure "exists locally but not on server" unless item.server
      end

      add_check "items are the same" do
        if item.server && item.local
          failure "#{item.server}\n  is not equal to\n  #{item.local}" unless item.server == item.local
        end
      end

      Role = Struct.new(:name, :server, :local)

      def items
        server_items   = items_on_server
        local_items    = items_in_repo
        all_item_names = ( server_items + local_items ).uniq.sort

        all_item_names.map do |name|
          Role.new.tap do |item|
            item.name   = name
            item.server = load_item_from_server(name)
            item.local  = load_item_from_local(name)
          end
        end
      end

      def items_on_server
        @items_on_server ||= Chef::Role.list.keys
      end

      def items_in_repo
        Dir.chdir("#{@context.repo_path}/roles") do
          Dir["*.rb"].map { |e| e.gsub(/\.(rb|json|js)/, '') }
        end
      end

      def load_item_from_server(name)
        role = Chef::Role.load(name)
        role.to_hash
      rescue
        nil
      end

      def load_item_from_local(name)
        if File.file?("#{@context.repo_path}/roles/#{name}.rb")
          role = Chef::Role.new
          role.from_file( "#{@context.repo_path}/roles/#{name}.rb" )
        elsif File.file?( "#{@context.repo_path}/roles/#{name}.js" )
          json =  Yajl::Parser.parse( IO.read (" #{@context.repo_path}/roles/#{name}.js" ))
          role = Chef::Role.json_create(json)
        elsif File.file?( "#{@context.repo_path}/roles/#{name}.json" )
          json =  Yajl::Parser.parse( IO.read ( "#{@context.repo_path}/roles/#{name}.json" ))
          role = Chef::Role.json_create(json)
        end
        if role
          role.to_hash
        else
          nil
        end
      rescue IOError
        nil
      end
    end

  end
end
