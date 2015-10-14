module Boundaries
  class Mock
    attr_reader :attributes, :class_stubs, :instance_stubs, :target

    def initialize(attributes = [], class_stubs = {}, instance_stubs = {}, transients = [], validators = [], target)
      accumulate = ->(arr, acc = BlockAccumulator) { arr.inject(acc.new(self)) { |acc, blk| acc.accumulate(&blk) }.serialize }
      @attributes = accumulate[attributes]
      @transients = accumulate[transients]
      @validators = accumulate[validators]

      @class_stubs = {}
      class_stubs.each_pair { |k,v| @class_stubs[k] = accumulate[v, StubAccumulator] }
      
      @instance_stubs = {}
      instance_stubs.each_pair { |k,v| @instance_stubs[k] = accumulate[v, StubAccumulator] }
      binding.pry 
      @target = target 
      @redefined_methods = {class: {}, instance: {}} 
   end

   

    def handle_message(m, sender, *args, &blk)
      sender_type, stubs = sender.is_a?(Class) ? [:class, @class_stubs] : [:instance, @instance_stubs]
      matched = stubs[m].find { |stub| stub.matches?(*args) }
      if matched
        @target.execute_prepared_block(matched.returns)
      else
        @redefined_methods[sender_type][m].bind(sender).call(*args, &blk)
      end
    end

    def mock!
      klass = target.target
      metaclass = klass.class_eval { class << self; self; end }
      @class_stubs.keys.each do |key|

        @redefined_methods[:class][key] = metaclass.instance_method(key) 
        #@redefined_methods[:class][key] = "aliased_class_#{key}"
        #metaclass.send(:alias_method, "aliased_#{key}", key)
        mocker = self
        metaclass.send(:define_method, key) do |*args, &blk| 
          mocker.handle_message(__method__, self, *args, &blk) 
        end
      end

      @instance_stubs.keys.each do |key|
        #@redefined_methods[:instance][key] = "aliased_instance_#{key}"
        @redefined_methods[:instance][key] = klass.instance_method(key) 
        #klass.send(:alias_method, "aliased_instance_#{key}", key)
        mocker = self
        klass.send(:define_method, key) do |*args, &blk| 
          mocker.handle_message(__method__, self, *args, &blk) 
        end
      end
    end

    def unmock!
      klass = target.target
      metaclass = klass.class_eval { class << self; self; end }
      @redefined_methods[:class].each do |k,v|
        metaclass.send(:define_method, k, v)
      end

      @redefined_methods[:instance].each do |k,v|
        klass.send(:define_method, k, v)
      end
      @redefined_methods = { class: [], instance: [] } 
      true
    end
  end
end
