require 'spec_helper'
include Boundaries

describe Definition do

  before(:each) { Definition.send(:public, *Definition.protected_instance_methods) }
  let(:foo) do
    foo = Definition.new(:foo)
    foo.attributes do
      attr1 :foo
    end

    foo.transients do
      attr2 :foo
    end

    foo.stubs(:get) do
      attr2 :foo
    end
    foo
  end

  describe 'defining' do
    before(:each) do
      @foo2 = Definition.new(:foo2)
    end
    it 'attributes' do
      @foo2.attributes do
        attr1 'foo'
      end
      expect(@foo2.get_attributes.first).to be_a(Proc)
    end

    it 'stubs' do
      prc = -> { bar :batz }
      stub = @foo2.stubs(:foo, &prc)
      expect(@foo2.get_stubs[:foo]).to include(prc)
    end
      
    it 'transients' do
      @foo2.transients{ bar :batz }
      expect(@foo2.get_transients.first).to be_a(Proc)
    end
  end

  describe 'extending' do
    before(:each) { @foo2 = Definition.new(:foo, extends: foo) }

    it 'attributes' do
      attrs = lambda { attr2 :foo }
      @foo2.attributes(&attrs)
      expected = [foo.get_attributes, attrs].flatten!
      expect(@foo2.get_attributes).to eq(expected)
    end

    it 'transients' do
      attrs = lambda { attr2 :foo }
      @foo2.transients(&attrs)
      expected = [foo.get_transients, attrs].flatten!
      expect(@foo2.get_transients).to eq(expected)
    end

    it 'stubs' do
      attrs = lambda { attr2 :asdf }
      @foo2.stubs(:get, &attrs)
      expected = foo.get_stubs[:get].concat([attrs])
      expect(@foo2.get_stubs[:get]).to eq(expected)
    end
  end

  describe 'generating' do
    before(:each) { @foo2 = Definition.new(:foo) }
    it 'creates a boundary mock' do
      expect(@foo2.generate).to be_a(Mock)
    end
  end
end
