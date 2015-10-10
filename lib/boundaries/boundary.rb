require 'rspec/mocks/standalone'
require 'boundaries/definition'

module Boundaries
  class BoundaryUndefined < StandardError; end

  class Boundary
    def self.inherited(klass)
      klass.class_eval do
        @defined = {}
        @caller = nil
        @definition = Class.new(Boundaries::Definition)
      end
    end

    def self.value_of(key)
      raise BoundaryUndefined if !@defined.include?(key)
      @defined[key].to_value
    end

    def self.mock_attributes(*symbols)
      @definition.set_mock_attributes(symbols)
    end

    def self.define(key, options={}, &blk)
      definition = @definition.new(key, self, options).instance_exec(&blk)
      definition.evaluate!(@defined, @mock_attributes)
      @defined[key] = definition
    end

    def self.prepare(klass)
      @caller = klass
    end

    def self.mock(key)
      @caller.instance_exec(target, @defined[key]) do |target, definition|
        allow(target).to receive(definition.meth).and_return(definition.to_value)
      end
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

    private

    def self.target
      self::TARGET
    end
  end
end
