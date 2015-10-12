module Boundaries
  class AttributeAccumulator

    def self.accumulate(*blks, &blk)
      blks << blk if blk
      new(*blks)
    end

    def initialize(*blks)
      @hash = {}
      blks.each { |b| instance_exec(&b) }
    end

    def accumulate(&blk)
      instance_exec(&blk)
    end

    def hashify(hash = nil)
      return hashify(@hash) if !hash
      hash.inject({}) do |h, (k,v) |
        v = v.hashify if v.respond_to?(:hashify)
        h.merge!(k => v)
      end
    end

    def method_missing(m, *args, &blk)
      args = args[0] if args.length == 1
      if blk
        if @hash[m]
          @hash[m].accumulate(&blk)
        else
          @hash[m] = AttributeAccumulator.accumulate(&blk)
        end
      else
        @hash[m] = args
      end
    end
  end

  class BoundaryMock
    def initialize(attributes = [], stubs = [], transients = [], validators = [])
      @attributes = AttributeAccumulator.accumulate(*attributes).hashify
    end

    def mock!(callback)
      @method_stubs.each do |config|
        rv = nil
        options = config[:options]
        if options && options[:returns]
          rv = return_value(options[:returns])
        end
        callback.call(config[:method], rv, *config[:arguments])
      end
    end
  end

  class MethodStub
    def initialize(m, *args)
    end
  end

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
      BoundaryMock.new(@attributes, @stubs, @transients, @validators)
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
