module Boundaries
  class Mock
    attr_reader :attributes, :stubs
    def initialize(attributes = [], stubs = [], transients = [], validators = [])
      accumulate = ->(arr, acc = BlockAccumulator) { arr.inject(acc.new) { |acc, blk| acc.accumulate(&blk) }.serialize }
      @attributes = accumulate[attributes]
      @transients = accumulate[transients]
      @validators = accumulate[validators]
  
      @stubs = {}
      stubs.each do  |s| 
        s.each_pair { |k,v| @stubs[k] = accumulate[v, StubAccumulator] } 
      end 
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
  end
end
