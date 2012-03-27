# encoding: UTF-8

module HealthInspector
  module Checklists
    class Base
      include Color

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
          puts color('bright yellow', "  #{message}")
        end
      end

    end
  end
end
