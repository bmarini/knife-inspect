module HealthInspector
  class Errors
    extend Forwardable
    def_delegators :@errors, :each, :empty?, :<<

    include Enumerable

    def initialize
      @errors = []
    end

    alias :add :<<
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
      recursive_diff(stringify_hash_keys(original), stringify_hash_keys(other))
    end

    def stringify_hash_keys(original)
      original.keys.inject({}) do |original_strkey, key|
        original_strkey[key.to_s] = stringify_item(original[key])
        original_strkey
      end
    end

    def stringify_item(item)
      if item.kind_of?(Hash)
        stringify_hash_keys(item)
      elsif item.kind_of?(Array)
        item.map {|array_item| stringify_item(array_item) }
      else # must be a string
        item
      end
    end

    def recursive_diff(original, other)
      (original.keys + other.keys).uniq.inject({}) do |memo, key|
        unless original[key] == other[key]
          if original[key].kind_of?(Hash) && other[key].kind_of?(Hash)
            diff = recursive_diff(original[key], other[key])
            memo[key] = diff unless diff.empty?
          else
            memo[key] = {"server" => original[key], "local" => other[key]}
          end
        end
        memo
      end
    end
  end

  # Mixins for common validations across pairings
  module ExistenceValidations
    def validate_existence
      if local.nil? && server.nil?
        errors.add "does not exist locally or on server"
        return
      end

      validate_local_copy_exists
      validate_server_copy_exists
    end

    private
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
