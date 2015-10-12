module Boundaries
  class Accumulator

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
      args.flatten!
      args = args[0] if args.length == 1
      if blk
        if @hash[m] && @hash[m].is_a?(Accumulator)
          @hash[m].accumulate(&blk)
        else
          @hash[m] = Accumulator.accumulate(&blk)
        end
      else
        @hash[m] = args
      end
    end
  end
end
