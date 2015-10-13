module Boundaries
  class Definition

    attr_reader :meth, :value

    def initialize(name, options = {})
      @name = name
      @stubs = Hash.new { |h, k| h[k] = [] }
      @validators = []
      @attributes = []
      @transients = []

      if options && extends = options[:extends]
        @stubs.merge!(extends.get_stubs) { |h, l, r| [].concat(r).concat(l)  }
        @validators.concat(extends.get_validators)
        @attributes.concat(extends.get_attributes)
        @transients.concat(extends.get_transients)
      end
    end

    def stubs(key, &blk)
      @stubs[key] << blk
    end


    def attributes(&blk)
      @attributes << blk
    end

    def transients(&blk)
      @transients << blk
    end

    def validates(sym = nil, &blk)
      @validators << Validator.new(sym, blk)
    end

    def actualize(target)
      Mock.new(@attributes, @stubs, @transients, @validators, target)
    end

    protected

    def get_attributes
      @attributes
    end

    def get_validators
      @validators
    end

    def get_stubs
      @stubs
    end

    def get_transients
      @transients
    end
  end
end
