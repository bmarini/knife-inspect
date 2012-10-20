require "chef/data_bag"

module HealthInspector
  module Checklists
    class DataBagItem < Pairing
      include ExistenceValidations
      include JsonValidations
    end

    class DataBagItems < Base
      title "data bag items"

      def each_item
        server_data_bag_items   = data_bag_items_on_server
        local_data_bag_items    = data_bag_items_in_repo
        all_data_bag_item_names = ( server_data_bag_items + local_data_bag_items ).uniq.sort

        all_data_bag_item_names.each do |name|
          item = DataBagItem.new(@context,
            :name   => name,
            :server => load_item_from_server(name),
            :local  => load_item_from_local(name)
          )

          yield item
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
        Yajl::Parser.parse( File.read("#{@context.repo_path}/data_bags/#{name}.json") )
      rescue IOError, Errno::ENOENT
        nil
      end
    end

  end
end
