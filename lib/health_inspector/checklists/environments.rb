require "chef/environment"

module HealthInspector
  module Checklists
    class Environment < Pairing
      include ExistenceValidations
      include JsonValidations

      # Override to ignore _default environment if it is missing locally
      def validate_local_copy_exists
        super unless name == '_default'
      end
    end

    class Environments < Base
      title "environments"

      def each_item
        server_items   = items_on_server
        local_items    = items_in_repo
        all_item_names = ( server_items + local_items ).uniq.sort

        all_item_names.each do |name|
          item = Environment.new(@context,
            :name   => name,
            :server => load_item_from_server(name),
            :local  => load_item_from_local(name)
          )

          yield item
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
