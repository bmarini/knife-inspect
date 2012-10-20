require "chef/data_bag"

module HealthInspector
  module Checklists
    class DataBag < Pairing
      include ExistenceValidations
    end

    class DataBags < Base
      title "data bags"

      def each_item
        all_item_names.each do |name|
          item = DataBag.new(@context,
            :name   => name,
            :server => server_items.include?(name),
            :local  => local_items.include?(name)
          )

          yield item
        end
      end

      def server_items
        @server_items ||= Chef::DataBag.list.keys
      end

      def local_items
        @local_items ||= Dir["#{@context.repo_path}/data_bags/*"].entries.
          select { |e| File.directory?(e) }.
          map { |e| File.basename(e) }
      end
    end

  end
end
