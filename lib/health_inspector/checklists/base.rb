# encoding: UTF-8
require 'pathname'
require 'yajl'
require 'parallel'

module HealthInspector
  module Checklists
    class Base
      include Color

      class << self
        attr_reader :title

        def title(val = nil)
          val.nil? ? @title : @title = val
        end
      end

      def self.run(knife)
        new(knife).run
      end

      def initialize(knife)
        @context = Context.new(knife)
      end

      def ui
        @context.knife.ui
      end

      def server_items
        fail NotImplementedError, 'You must implement this method in a subclass'
      end

      def local_items
        fail NotImplementedError, 'You must implement this method in a subclass'
      end

      def all_item_names
        (server_items + local_items).uniq.sort
      end

      def load_validate(name)
        item = load_item(name)
        validate_item(item)
      end

      def run
        banner "Inspecting #{self.class.title}"

        results = Parallel.map(all_item_names) do |name|
          load_validate(name)
        end

        !results.include?(false)
      end

      def validate_item(item)
        item.validate
        failures = item.errors

        if failures.empty?
          print_success(item.name)

          true
        else
          print_failures(item.name, failures)

          false
        end
      end

      def banner(message)
        ui.msg ''
        ui.msg message
        ui.msg '-' * 80
      end

      def print_success(subject)
        if $stdout.tty?
          ui.msg color('bright pass', "✓") + " #{subject}"
        else
          ui.msg "Success #{subject}"
        end
      end

      def print_failures(subject, failures)
        ui.msg color('bright fail', "- #{subject}")

        failures.each do |message|
          if message.is_a? Hash
            puts color('bright yellow', "  has the following values mismatched on the server and repo\n")
            print_failures_from_hash(message)
          else
            puts color('bright yellow', "  #{message}")
          end
        end
      end

      def print_failures_from_hash(message, depth = 2)
        message.keys.each do |key|
          print_key(key, depth)

          if message[key].include? 'server'
            print_value_diff(message[key], depth)
            message[key].delete_if { |k, _| k == 'server' || 'local' }
            print_failures_from_hash(message[key], depth + 1) unless message[key].empty?
          else
            print_failures_from_hash(message[key], depth + 1)
          end
        end
      end

      def print_key(key, depth)
        ui.msg indent(color('bright yellow', "#{key} : "), depth)
      end

      def print_value_diff(value, depth)
        print indent(color('bright fail', 'server value = '), depth + 1)
        print value['server']
        print "\n"
        print indent(color('bright fail', 'local value  = '), depth + 1)
        print value['local']
        print "\n\n"
      end

      def load_ruby_or_json_from_local(chef_class, folder, name)
        path_template = "#{@context.repo_path}/#{folder}/**/#{name}.%s"
        ruby_pathname = Pathname.glob(path_template % 'rb')
        json_pathname = Pathname.glob(path_template % 'json')
        js_pathname   = Pathname.glob(path_template % 'js')

        if !ruby_pathname.empty?
          instance = chef_class.new
          instance.from_file(ruby_pathname.first.to_s)
        elsif !json_pathname.empty?
          instance = chef_class.json_create(Yajl::Parser.parse(json_pathname.first.read))
        elsif !js_pathname.empty?
          instance = chef_class.json_create(Yajl::Parser.parse(js_pathname.first.read))
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
