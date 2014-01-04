require "chef/role"
require 'yajl'

module HealthInspector
  module Checklists
    class Role < Pairing
      include ExistenceValidations
      include JsonValidations
    end

    class Roles < Base
      title "roles"

      def each_item
        all_item_names.each do |name|
          yield load_item(name)
        end
      end

      def load_item(name)
        Role.new(@context,
          :name   => name,
          :server => load_item_from_server(name),
          :local  => load_item_from_local(name)
        )
      end

      def server_items
        @server_items ||= Chef::Role.list.keys
      end

      def local_items
        Dir["#{@context.repo_path}/roles/*.{rb,json,js}"].map do |e|
          File.basename(e, '.*')
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
