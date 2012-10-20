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
        all_item_names.each do |name|
          item = DataBagItem.new(@context,
            :name   => name,
            :server => load_item_from_server(name),
            :local  => load_item_from_local(name)
          )

          yield item
        end
      end

      def server_items
        @server_items ||= Chef::DataBag.list.keys.map do |bag_name|
          [ bag_name, Chef::DataBag.load(bag_name) ]
        end.inject([]) do |arr, (bag_name, data_bag)|
          arr += data_bag.keys.map { |item_name| "#{bag_name}/#{item_name}"}
        end
      end

      def local_items
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
