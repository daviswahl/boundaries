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
end
