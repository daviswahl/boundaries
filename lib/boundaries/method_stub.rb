module Boundaries
  class MethodStub
    def initialize(*args, &blk)
      args.flatten!
      args = args[0] if args.length == 1
      @arguments = args
      @block = blk
    end
    
    def and_returns(*args, &blk)

    end
    private
    attr_reader :arguments
  end
end
