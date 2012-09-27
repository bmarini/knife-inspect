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
          item_diff = diff(item.server, item.local)
          failure item_diff unless item_diff.empty?
        end
      end

      Role = Struct.new(:name, :server, :local)

      def each_item
        server_items   = items_on_server
        local_items    = items_in_repo
        all_item_names = ( server_items + local_items ).uniq.sort

        all_item_names.each do |name|
          item = Role.new.tap do |item|
            item.name   = name
            item.server = load_item_from_server(name)
            item.local  = load_item_from_local(name)
          end

          yield item
        end
      end

      def items_on_server
        @items_on_server ||= Chef::Role.list.keys
      end

      def items_in_repo
        Dir.chdir("#{@context.repo_path}/roles") do
          Dir["*.{rb,json,js}"].map { |e| e.gsub(/\.(rb|json|js)/, '') }
        end
      end

      def load_item_from_server(name)
        role = Chef::Role.load(name)
        role.to_hash
      rescue
        nil
      end

      def load_item_from_local(name)
        load_ruby_or_json_from_local(Chef::Role, "roles", name)
      end
    end

  end
end
