require "chef/environment"

module HealthInspector
  module Checklists
    class Environment < Pairing
      include ExistenceValidations
      include JsonValidations

      private
      # Override to ignore _default environment if it is missing locally
      def validate_local_copy_exists
        super unless name == '_default'
      end
    end

    class Environments < Base
      title "environments"

      def load_item(name)
        Environment.new(@context,
          :name   => name,
          :server => load_item_from_server(name),
          :local  => load_item_from_local(name)
        )
      end

      def server_items
        @server_items ||= Chef::Environment.list.keys
      end

      def local_items
        Dir["#{@context.repo_path}/environments/**/*.{rb,json,js}"].map do |e|
          File.basename(e, '.*')
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
