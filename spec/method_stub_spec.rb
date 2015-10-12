require 'spec_helper'
include Boundaries

describe MethodStub do
  describe 'setting attributes' do
    before(:each) { MethodStub.send(:public, *MethodStub.private_instance_methods) }

    let(:put) { { :put => [ lambda { allows :bat } ] } } 
    let(:get) { { :get => [ lambda { allows :search; allows :bar }, lambda { allows :foo } ] } }

    it 'evaluates attributes' do
      foo = Mock.new([], [put, get])
      
      expect(foo.stubs[:put].first.arguments).to eq(:bat)

    end

    it 'nested attrs' do
      #foo = Mock.new(nested_attrs)
    end
    it 'inherited attrs' do
      #foo = Mock.new(inherit_attrs)
    end
    it 'inherited nested attrs', wip: true do
      #foo = Mock.new(nested_inherit_attrs)
    end
  end
end
