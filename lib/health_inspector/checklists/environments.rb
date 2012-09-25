require "chef/environment"

module HealthInspector
  module Checklists
    class Environments < Base
      title "environments"

      add_check "local copy exists" do
        failure "exists on server but not locally" unless item.local
      end

      add_check "server copy exists" do
        failure "exists locally but not on server" unless item.server
      end

      add_check "items are the same" do
        if item.server && item.local
          environment_diff = diff(item.server,item.local)
          failure environment_diff unless environment_diff.empty?
        end
      end

      Environment = Struct.new(:name, :server, :local)

      def items
        server_items   = items_on_server
        local_items    = items_in_repo
        all_item_names = ( server_items + local_items ).uniq.sort

        all_item_names.map do |name|
          Environment.new.tap do |item|
            item.name   = name
            item.server = load_item_from_server(name)
            item.local  = load_item_from_local(name)
          end
        end
      end

      def items_on_server
        @items_on_server ||= Chef::Environment.list.keys
      end

      def items_in_repo
        Dir.chdir("#{@context.repo_path}/environments") do
          Dir["*.{rb,json,js}"].map { |e| e.gsub(/\.(rb|json|js)/,"") }
        end
      end

      def load_item_from_server(name)
        env = Chef::Environment.load(name)
        env.to_hash
      rescue
        nil
      end

      def load_item_from_local(name)
        load_ruby_or_json_from_local(Chef::Environment, "environments", name)
      end
    end

  end
end
