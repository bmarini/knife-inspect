module HealthInspector
  class Errors
    include Enumerable

    def initialize
      @errors = []
    end

    def add(message)
      @errors << message
    end

    def each
      @errors.each { |e| yield(e) }
    end

    def empty?
      @errors.empty?
    end
  end

  class Pairing
    attr_accessor :name, :local, :server
    attr_reader :context, :errors

    def initialize(context, opts={})
      @context     = context
      @name        = opts[:name]
      @local       = opts[:local]
      @server      = opts[:server]

      @validations = []
      @errors      = Errors.new
    end

    def validate
      self.methods.grep(/^validate_/).each { |meth| send(meth) }
    end

    def hash_diff(original, other)
      (original.keys + other.keys).uniq.inject({}) do |memo, key|
        unless original[key] == other[key]
          if original[key].kind_of?(Hash) && other[key].kind_of?(Hash)
            memo[key] = diff(original[key], other[key])
          else
            memo[key] = {"server" => original[key],"local" => other[key]}
          end
        end
        memo
      end
    end
  end

  # Mixins for common validations across pairings
  module ExistenceValidations
    def validate_local_copy_exists
      errors.add "exists on server but not locally" if local.nil?
    end

    def validate_server_copy_exists
      errors.add "exists locally but not on server" if server.nil?
    end
  end

  module JsonValidations
    def validate_items_are_the_same
      if server && local
        differences = hash_diff(server, local)
        errors.add differences unless differences.empty?
      end
    end
  end
end