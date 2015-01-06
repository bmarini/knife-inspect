require 'chef/data_bag'
require 'yajl'

module HealthInspector
  module Checklists
    class DataBagItem < Pairing
      include ExistenceValidations
      include JsonValidations
    end

    class DataBagItems < Base
      def load_item(name)
        DataBagItem.new(@context,
                        name: name,
                        server: load_item_from_server(name),
                        local: load_item_from_local(name)
        )
      end

      def server_items
        @server_items ||= Chef::DataBag.list.keys.map do |bag_name|
          [bag_name, Chef::DataBag.load(bag_name)]
        end.reduce([]) do |arr, (bag_name, data_bag)|
          arr + data_bag.keys.map { |item_name| "#{bag_name}/#{item_name}" }
        end
      end

      # JSON files are data bag items, their parent folder is the data bag
      def local_items
        Dir["#{@context.repo_path}/data_bags/**/*.json"].map do |e|
          e.split('/')[-2..-1].join('/').gsub('.json', '')
        end
      end

      def load_item_from_server(name)
        bag_name, item_name = name.split('/')
        Chef::DataBagItem.load(bag_name, item_name).raw_data
      rescue Net::HTTPServerException
        nil
      end

      # We support data bags that are inside a folder or git submodule, for
      # example:
      #
      # data_bags/corp/apps/some_app.json is in the repo, but apps/some_app on
      # the server
      def load_item_from_local(name)
        local_data_bag_item = Dir["#{@context.repo_path}/data_bags/**/#{name}.json"].first
        return nil if local_data_bag_item.nil?

        Yajl::Parser.parse(File.read(local_data_bag_item))
      rescue Yajl::ParseError
        nil
      end
    end
  end
end
