require "chef/data_bag"

module HealthInspector
  module Checklists
    class DataBags < Base
      title "data bags"

      add_check "local copy exists" do
        failure "exists on server but not locally" unless item.exists_locally
      end

      add_check "server copy exists" do
        failure "exists locally but not on server" unless item.exists_on_server
      end

      DataBag = Struct.new(:name, :exists_on_server, :exists_locally)

      def items
        server_data_bags   = data_bags_on_server
        local_data_bags    = data_bags_in_repo
        all_data_bag_names = ( server_data_bags + local_data_bags ).uniq.sort

        all_data_bag_names.map do |name|
          DataBag.new.tap do |data_bag|
            data_bag.name = name
            data_bag.exists_on_server = data_bags_on_server.include?(name)
            data_bag.exists_locally = data_bags_in_repo.include?(name)
          end
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
