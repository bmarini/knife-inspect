require "chef/data_bag"

module HealthInspector
  module Checklists
    class DataBag < Pairing
      include ExistenceValidations
    end

    class DataBags < Base
      title "data bags"

      def each_item
        server_data_bags   = data_bags_on_server
        local_data_bags    = data_bags_in_repo
        all_data_bag_names = ( server_data_bags + local_data_bags ).uniq.sort

        all_data_bag_names.each do |name|
          item = DataBag.new(@context,
            :name   => name,
            :server => data_bags_on_server.include?(name),
            :local  => data_bags_in_repo.include?(name)
          )

          yield item
        end
      end

      def data_bags_on_server
        @data_bags_on_server ||= Chef::DataBag.list.keys
      end

      def data_bags_in_repo
        @data_bags_in_repo ||= Dir["#{@context.repo_path}/data_bags/*"].entries.
          select { |e| File.directory?(e) }.
          map { |e| File.basename(e) }
      end
    end

  end
end
