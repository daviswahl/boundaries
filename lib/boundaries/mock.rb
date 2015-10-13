module Boundaries
  class Mock
    attr_reader :attributes, :stubs, :target

    def initialize(attributes = [], stubs = {}, transients = [], validators = [], target)
      accumulate = ->(arr, acc = BlockAccumulator) { arr.inject(acc.new) { |acc, blk| acc.accumulate(&blk) }.serialize }
      @attributes = accumulate[attributes]
      @transients = accumulate[transients]
      @validators = accumulate[validators]
  
      @stubs = {}
      stubs.each_pair { |k,v| @stubs[k] = accumulate[v, StubAccumulator] }
     
      @target = target 
   end
  
    def handle_message(m, *args, &blk)
      matched = @stubs[m].find { |stub| stub.matches?(*args) }
      binding.pry
      if matched
        @target.instance_exec(matched.returns)
      else
        @target.replaced_methods[m].call(*args, &blk)
      end
    end

    def mock!
      binding.pry
    end
  end
end
