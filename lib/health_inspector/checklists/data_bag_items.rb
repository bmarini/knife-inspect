require "chef/data_bag"

module HealthInspector
  module Checklists
    class DataBagItems < Base
      title "data bag items"

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

      DataBagItem = Struct.new(:name, :server, :local)

      def items
        server_data_bag_items   = data_bag_items_on_server
        local_data_bag_items    = data_bag_items_in_repo
        all_data_bag_item_names = ( server_data_bag_items + local_data_bag_items ).uniq.sort

        all_data_bag_item_names.map do |name|
          DataBagItem.new.tap do |data_bag_item|
            data_bag_item.name   = name
            data_bag_item.server = load_item_from_server(name)
            data_bag_item.local  = load_item_from_local(name)
          end
        end
      end

      def data_bag_items_on_server
        @data_bags_on_server ||= Chef::DataBag.list.keys.map do |bag_name|
          [ bag_name, Chef::DataBag.load(bag_name) ]
        end.inject([]) do |arr, (bag_name, data_bag)|
          arr += data_bag.keys.map { |item_name| "#{bag_name}/#{item_name}"}
        end
      end

      def data_bag_items_in_repo
        entries = nil

        Dir.chdir("#{@context.repo_path}/data_bags") do
          entries = Dir["**/*.json"].map { |entry| entry.gsub('.json', '') }
        end

        return entries
      end

      def load_item_from_server(name)
        bag_name, item_name = name.split("/")
        Chef::DataBagItem.load(bag_name, item_name).raw_data
      rescue
        nil
      end

      def load_item_from_local(name)
        JSON.parse( File.read("#{@context.repo_path}/data_bags/#{name}.json") )
      rescue
        nil
      end
    end

  end
end
