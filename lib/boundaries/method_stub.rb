module Boundaries
  class PreparedBlock
    attr_reader :block, :arguments
    def initialize(args=nil, &blk)
      @arguments = args
      @block = blk
    end

    def call
      @block.call(*@arguments)
    end

    def ==(other)
      return (other.block == block && other.arguments == arguments)
    end
  end

  class MethodStub
    def initialize(*args)
      args.flatten!
      @arguments = args
    end
    
    def and_returns(*args, &blk)
      args.flatten!
      args = args[0] if args.length == 1
      @returns = { value: args, block: blk }
    end

    def and_validates_with(symbol = nil, &blk)
      @validates = symbol || blk
    end

    def matches?(*args)
      @arguments == args
    end
    
    def returns
      v = @returns[:value]
      blk = @returns[:block]
      return PreparedBlock.new(v, &blk)
    end
    private
    attr_reader :arguments, :block, :validates
  end
end
