require 'rspec/mocks/standalone'
require 'rspec/expectations'
require 'boundaries/definition'

module Boundaries
  class BoundaryUndefined < StandardError; end

  class Boundary
    extend RSpec::Matchers

    def self.inherited(klass)
      klass.class_eval do
        @definitions = {}
        @caller = nil
      end
    end

    def self.value_of(key, return_key = nil)
      raise BoundaryUndefined if !@defined.include?(key)
      @defined[key].return_value(return_key)
    end

    def self.define(key, options={}, &blk)
      definition = Boundaries::Definition.new(key, self, options)
      definition.instance_exec(&blk)

      @definitions[key] = definition
      #@mocks[key] = BoundaryMock.new(definition)
    end

    def self.list
      @defined.keys
    end

    def self.get(key)
      @defined[key]
    end

    def self.target(target = nil)
      @target = target if target
      @target
    end

    def self.interface
    end

    def self.mock(key)
      @defined[key].mock!(@class_interface_callback)
    end

    def self.class_interface(&blk)
      @class_interface_callback = blk
    end

    def self.run_tests
      test_cases.each do |k, test_case|
        @caller.instance_exec(target, test_case) do |target, test_case|
          expect(target.send(test_case.meth)).to eql(test_case.to_value)
        end
      end
    end

    def self.test_cases
      @defined.select { |_,v| v.validates? }
    end

    def self.to_value(hash)
      hash
    end

    def self.clear
      @defined = {}
    end

    def self.validate(definition)
      #actual = target.send(definition.meth, definition.accepts)
      #raise "Undefined validation strategy" if !respond_to?(definition.validate_strategy)
      #send(definition.validate_strategy, actual, definition.to_value)
    end
  end
end
