module Boundaries
  class Definition

    attr_reader :meth, :value

    def initialize(name, options = {})
      @name = name
      @stubs = []
      @validators = []
      @attributes = []
      @transients = []

      if options && extends = options[:extends]
        @stubs.concat(extends.get_stubs)
        @validators.concat(extends.get_validators)
        @attributes.concat(extends.get_attributes)
        @transients.concat(extends.get_transients)
      end
    end

    def stubs(m, *args)
      stub = MethodStub.new(m, *args)
      @stubs << stub
      stub
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

    def generate
      Mock.new(@attributes, @stubs, @transients, @validators)
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
