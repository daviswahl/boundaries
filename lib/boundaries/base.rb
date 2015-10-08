module Boundaries
  class BoundaryUndefined < StandardError; end

  class Boundary

    DEFAULT_HASH = {}

    def self.inherited(klass)
      klass.class_eval do
        @defined = {}
      end
    end

    def self.value_of(key)
      raise BoundaryUndefined if !@defined.include?(key)
      @defined[key].value[:value]
    end

    def self.define(key, &blk)
      definition = Definition.new.instance_exec(&blk)
      @defined[key] = definition
    end

    def self.mock(key)
      definition = @defined[key]
      binding.pry
    end

    private
    def self.mocks
      self::MOCKS
    end
  end

  class Definition

    def mocks(symbol)
      @mocks = symbol
    end

    def accepts(args)
      @accepts = args
      self
    end

    def value
      @returns
    end

    def returns(args, sym = nil, &blk)
      @returns = { value: args, by: sym || blk }
      self
    end

    def validates(args)
      @validates = args
      self
    end
  end
end
