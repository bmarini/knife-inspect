require 'chef/data_bag'

module HealthInspector
  module Checklists
    class DataBag < Pairing
      include ExistenceValidations
    end

    class DataBags < Base
      def load_item(name)
        DataBag.new(@context,
                    name: name,
                    server: server_items.include?(name),
                    local: local_items.include?(name)
        )
      end

      def server_items
        @server_items ||= Chef::DataBag.list.keys
      end

      # JSON files are data bag items, their parent folder is the data bag
      def local_items
        @local_items ||= Dir["#{@context.repo_path}/data_bags/**/*.json"].map do |e|
          e.split('/')[-2].gsub('.json', '')
        end
      end
    end
  end
end
