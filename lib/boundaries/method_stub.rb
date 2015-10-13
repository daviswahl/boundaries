module Boundaries
  class MethodStub
    def initialize(*args)
      args.flatten!
      args = args[0] if args.length == 1
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
      binding.pry
      return v if v && !blk
      return blk if blk && !v
      return blk.curry(v)
    end
    private
    attr_reader :arguments, :block, :validates
  end
end
