module Boundaries
  class Mock
    attr_reader :attributes
    def initialize(attributes = [], stubs = [], transients = [], validators = [])
      @attributes = Accumulator.accumulate(*attributes).hashify
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
