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
    private
    attr_reader :arguments, :returns, :block
  end
end
