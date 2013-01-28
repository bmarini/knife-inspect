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
        mapped = item.map {|array_item| stringify_item(array_item) }
        mapped.sort {|a,b| heterogeneous_sort(a,b)}
      else # must be a string
        item
      end
    end
    
    def heterogeneous_sort(a, b)
      a_class = a.class.to_s
      b_class = b.class.to_s
      
      if a.kind_of?(Hash) && b.kind_of?(Hash)
        a.keys.sort.join <=> b.keys.sort.join
      elsif a_class == b_class
        return a <=> b
      else
        return a_class <=> b_class
      end
    end
  
    def recursive_diff(original, other)
      if original.kind_of?(Hash) && other.kind_of?(Hash)
        (original.keys + other.keys).uniq.inject({}) do |memo, key|
          unless original[key] == other[key]
            if original[key].kind_of?(Hash) && other[key].kind_of?(Hash)
              diff = recursive_diff(original[key], other[key])
              memo[key] = diff unless diff.empty?
            elsif original[key].kind_of?(Array) && other[key].kind_of?(Array) && original.size == other.size
              all_diffs = []
              original.each_index do |idx|
                diff = recursive_diff(original[idx], other[idx])
                all_diffs << diff unless diff.nil? || diff.empty?
              end
              memo[key] = all_diffs
            else
              memo[key] = {"server" => original[key], "local" => other[key]}
            end
          end
          memo
        end
      else
        return original == other
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