require 'spec_helper'
include Boundaries

describe MethodStub do
  describe 'setting attributes' do
    before(:each) { MethodStub.send(:public, *MethodStub.private_instance_methods) }

    let(:acc) { StubAccumulator }
    let(:with_foo)               { acc.new.accumulate(&-> { with(:foo) }) } 
    let(:foo) { with_foo.serialize.first }
    let(:with_foo_with_return)  { acc.new.accumulate(&-> { with(:foo).and_returns(:bar) }) }
    let(:a_proc) { proc { |b| b.to_s } }

    let(:with_foo_with_return_block)  { prc = a_proc; acc.new.accumulate(&-> { with(:foo).and_returns(:bar, &prc) }) }

    let(:foo_with_return) { with_foo_with_return.serialize.first }

    let(:foo_with_return_block) { with_foo_with_return_block.serialize.first }

    it 'can set return values' do
      expect(foo_with_return.returns).to eq({ value: :bar, block: nil})
    end

    it 'can set return block' do
      expect(foo_with_return_block.returns).to eq({ value: :bar, block: a_proc})
    end

    it 'can set arguments' do
      expect(foo.arguments).to eq(:foo)
    end
  end
end 
