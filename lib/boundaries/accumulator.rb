module Boundaries
  class BlockAccumulator

    def initialize(mock)
      @mock = mock
      @acc = {}
    end

    def accumulate(&blk)
      instance_exec(&blk)
      self
    end

    def self.accumulate(mock, &blk)
      acc = new(mock)
      acc.accumulate(&blk)
      acc
    end

    def serialize(acc = nil)
      return serialize(@acc) if !acc
      acc.inject({}) do |h, (k,v) |
        v = v.serialize if v.respond_to?(:serialize)
        h.merge!(k => v) if h.is_a? Hash
      end
    end
    def method_missing(m, *args, &blk)
      args.flatten!
      args = args[0] if args.length == 1
      if blk
        if @acc[m] && @acc[m].is_a?(BlockAccumulator)
          @acc[m].accumulate(&blk)
        else
          @acc[m] = BlockAccumulator.accumulate(@mock, &blk)
        end
      else
        @acc[m] = args
      end
    end
  end

  class StubAccumulator < BlockAccumulator
    def initialize(mock)
      @mock = mock
      @acc = []
    end

    def attributes
      @mock.attributes
    end


    def serialize(acc = nil)
      return serialize(@acc) if !acc
      acc.inject([]) do |h, v|
        v = v.serialize if v.respond_to?(:serialize)
        h << v if h.is_a? Array
      end
    end
    def with(*args)
      stub = MethodStub.new(*args)
      @acc << stub
      stub
    end

    def method_missing(m, *args, &blk)
      self.class.send(:method_missing, m, *args, &blk)
    end
  end
end
