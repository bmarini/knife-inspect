require 'chef/knife'

class Chef
  class Knife
    class DataBagInspect < Knife

      deps do
        require 'health_inspector'
      end

      banner "knife data bag inspect [BAG] [ITEM] (options)"

      def run
        case @name_args.length
        when 2 # We are inspecting a data bag item
          bag_name  = @name_args[0]
          item_name = @name_args[1]

          validator = HealthInspector::Checklists::DataBagItems.new(self)
          exit validator.validate_item( validator.load_item("#{bag_name}/#{item_name}") )

        when 1 # We are inspecting a data bag
          bag_name = @name_args[0]

          validator = HealthInspector::Checklists::DataBags.new(self)
          exit validator.validate_item( validator.load_item(bag_name) )

        when 0 # We are inspecting all the data bags
          exit HealthInspector::Checklists::DataBags.run(self) &&
               HealthInspector::Checklists::DataBagItems.run(self)
        end
      end
    end
  end
end
