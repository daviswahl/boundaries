module Boundaries
  class Definition

    attr_reader :meth, :value

    def initialize(name, options = {})
      @name = name
      @class_stubs = Hash.new { |h, k| h[k] = [] }
      @instance_stubs = Hash.new { |h, k| h[k] = [] }
      @validators = []
      @attributes = []
      @transients = []

      if options && extends = options[:extends]
        @instance_stubs.merge!(extends.get_instance_stubs) { |h, l, r| [].concat(r).concat(l)  }
        @class_stubs.merge!(extends.get_class_stubs) { |h, l, r| [].concat(r).concat(l)  }
        @validators.concat(extends.get_validators)
        @attributes.concat(extends.get_attributes)
        @transients.concat(extends.get_transients)
      end
    end

    def instance_stub(key, &blk)
      @instance_stubs[key] << blk
    end
    
    def class_stub(key, &blk)
      @class_stubs[key] << blk
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
      Mock.new(@attributes, @class_stubs, @instance_stubs, @transients, @validators, target)
    end

    protected

    def get_attributes
      @attributes
    end

    def get_validators
      @validators
    end

    def get_instance_stubs
      @instance_stubs
    end

    def get_class_stubs
      @class_stubs
    end

    def get_transients
      @transients
    end
  end
end
