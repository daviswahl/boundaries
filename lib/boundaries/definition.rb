module Boundaries
  class ValueBox < BasicObject

    def initialize(value = nil, *blocks)
      if value
        @value = value
      else
        @value = {}
        blocks.each { |blk| instance_exec(&blk) }
      end
    end

    def []
      @value
    end

    def method_missing(m, args = nil, &block)
      return @value[m] = args if args
      super
    end
  end

  class Value
    def initialize(val = nil, &blk)
      @procs = []
      @val = val
      @procs << blk if blk
    end

    def inherit(other_value)
      @procs = other_value.procs.dup.concat(procs)
      @val = other_value.value
      @marshals_with = other_value.marshals
      self
    end

    def evaluate!
      @value = ValueBox.new(@val, *@procs)
      self
    end

    def marshals_with(key = nil, &blk)
      @marshals_with = key || blk
    end

    def marshal(target)
      return @value[] if !@marshals_with
      if @value[].respond_to?(@marshals_with)
        @value[].send(@marshals_with)
      else
        target.send(@marshals_with, @value[])
      end
    end

    protected
    def procs
      @procs
    end

    def marshals
      @marshals_with
    end

    def value
      @val
    end

  end

  class Definition

    attr_reader :meth, :value

    def initialize(name, target, options = {})
      @name = name
      @target = target
      @method_stubs = []
      @attributes = Value.new(nil)

      if options && options[:extends]
        @extends = options[:extends]
      end
    end

    def mocks(symbol = nil)
      return @meth if symbol.nil?
      @meth = symbol
    end

    def stubs(m, *args, &blk)
      setup = {}
      setup[:method] = m
      setup[:options] =  args.reject { |h| h.is_a? Hash }
      setup[:arguments] = args
      setup[:block] = blk
      @method_stubs << setup
      self
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

    def attributes(&blk)
      @attributes = Value.new(value, &blk)
    end

    def validates(sym = nil, &blk)
      return @validates if sym.nil? && !blk
      if sym == false
        @validates = false
        return self
      end
      @validates = true
      @validate_strategy = sym || blk
      self
    end

    def evaluate!(definitions, attributes)
      extending_class = nil
      if @extends
        extending_class = definitions[@extends]
        raise if extending_class.nil?
        @meth ||= extending_class.meth
        @method_stubs.concat extending_class.method_stubs
        @validates = extending_class.validates if @validates.nil?
        @validate_strategy ||= extending_class.validate_strategy if @validates
        @attributes.inherit(extending_class.get_attributes)
      end
      @attributes.evaluate!
    end

    def to_hash
    end

    def validate_strategy
      @validate_strategy
    end

    def stubbed_methods
      @method_stubs
    end

    protected
    def method_stubs
      @method_stubs
    end

    def get_attributes
      @attributes
    end
    private


  end
end
