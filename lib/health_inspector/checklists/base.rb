# encoding: UTF-8
require "pathname"

module HealthInspector
  module Checklists
    class Base
      include Color

      class << self
        attr_reader :title

        def title(val=nil)
          val.nil? ? @title : @title = val
        end
      end

      def self.run(context)
        new(context).run
      end

      def initialize(context)
        @context = context
      end

      def all_item_names
        ( server_items + local_items ).uniq.sort
      end

      # Subclasses should collect all items from the server and the local repo,
      # and for each item pair, yield an object that contains a reference to
      # the server item, and the local repo item. A reference can be nil if it does
      # not exist in one of the locations.
      def each_item
        raise NotImplementedError, "You must implement this method in a subclass"
      end

      def run
        banner "Inspecting #{self.class.title}"

        each_item do |item|
          item.validate
          failures = item.errors

          if failures.empty?
            print_success(item.name) unless @context.quiet_success
          else
            print_failures(item.name, failures)
          end
        end
      end

      def chef_rest
        @context.chef_rest
      end

      def banner(message)
        puts
        puts message
        puts "-" * 80
      end

      def print_success(subject)
        puts color('bright pass', "✓") + " #{subject}"
      end

      def print_failures(subject, failures)
        puts color('bright fail', "- #{subject}")

        failures.each do |message|
          if message.kind_of? Hash
            puts color('bright yellow',"  has the following values mismatched on the server and repo\n")
            print_failures_from_hash(message)
          else
            puts color('bright yellow', "  #{message}")
          end
        end
      end

      def print_failures_from_hash(message, depth=2)
        message.keys.each do |key|
          print_key(key,depth)

          if message[key].include? "server"
            print_value_diff(message[key],depth)
            message[key].delete_if { |k,v| k == "server" || "local" }
            print_failures_from_hash(message[key], depth + 1) unless message[key].empty?
          else
            print_failures_from_hash(message[key], depth + 1)
          end
        end
      end

      def print_key(key, depth)
        puts indent( color('bright yellow',"#{key} : "), depth )
      end

      def print_value_diff(value, depth)
        print indent( color('bright fail',"server value = "), depth + 1 )
        print value["server"]
        print "\n"
        print indent( color('bright fail',"local value  = "), depth + 1 )
        print value["local"] 
        print "\n\n"
      end

      def load_ruby_or_json_from_local(chef_class, folder, name)
        path_template = "#{@context.repo_path}/#{folder}/#{name}.%s"
        ruby_pathname = Pathname.new(path_template % "rb")
        json_pathname = Pathname.new(path_template % "json")
        js_pathname   = Pathname.new(path_template % "js")

        if ruby_pathname.exist?
          instance = chef_class.new
          instance.from_file(ruby_pathname.to_s)
        elsif json_pathname.exist?
          instance = chef_class.json_create( Yajl::Parser.parse( json_pathname.read ) )
        elsif js_pathname.exist?
          instance = chef_class.json_create( Yajl::Parser.parse( js_pathname.read ) )
        end

        instance ? instance.to_hash : nil
      rescue IOError
        nil
      end

      def indent(string, depth)
        (' ' * 2 * depth) + string
      end

    end
  end
end
