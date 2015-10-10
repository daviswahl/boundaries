module Boundaries
  class Definition

    attr_reader :meth, :value

    def initialize(name, target, options = {})
      @name = name
      @boundary_target = target
      if options && options[:extends]
        @extends = options[:extends]
      end
    end

    def self.set_mock_attributes(attrs)
      @mock_attributes = attrs
      attrs.each do |attribute|
        define_method(attribute) { |value| instance_variable_set("@#{__method__}", value) }
      end
    end

     def mocks(symbol)
      @meth = symbol
    end

    def accepts(args)
      @accepts = args
      self
    end

    def to_value
      @boundary_target.to_value(to_hash)
    end

    def returns(&blk)
      @returns = blk
      self
    end

    def validates?
      @validates
    end

    def validates(sym = nil, &blk)
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
        instance_exec(&extending_class.get_returns)
        @meth ||= extending_class.get_meth
        @accepts ||= extending_class.get_accepts
        @validates = extending_class.get_validates if @validates.nil?
        @validate_strategy ||= extending_class.get_validate_strategy if @validates
      end
      @returns.call if @returns
    end

    def to_hash
      hash = {}
      self.class.mock_attributes.each do |k|
        hash[k] = instance_variable_get("@#{k}")
      end
      hash
    end

    def get_returns
      @returns
    end

    def get_accepts
      @accepts
    end

    def get_validates
      @validates
    end

    def get_validate_strategy
      @validate_strategy
    end

    def get_meth
      @meth
    end

    private
    def self.mock_attributes
      @mock_attributes
    end


  end
end
