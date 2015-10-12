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

    foo.stubs(:bar, :a)
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
      stub = @foo2.stubs(:bar, :batz)
      expect(@foo2.get_stubs).to contain_exactly(stub)
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
      stub = @foo2.stubs(:b, :asdf)
      expected = [foo.get_stubs, stub].flatten!
      expect(@foo2.get_stubs).to eq(expected)
    end
  end

  describe 'generating' do
    before(:each) { @foo2 = Definition.new(:foo) }
    it 'creates a boundary mock' do
      expect(@foo2.generate).to be_a(BoundaryMock)
    end
  end
end

describe BoundaryMock do
  let(:mock) { BoundaryMock }
  describe 'setting attributes' do

    let(:attrs) { [ lambda { base_attr :base; override_attr :base } ] }
    let(:nested_attrs) { [ lambda { base_attr :base; override_attr(){ attr :base; attr1 :base } } ] }
    let(:inherit_attrs) { [ attrs, lambda { override_attr :new_value; new_attr :new_value } ].flatten! }
    let(:nested_inherit_attrs) { [ nested_attrs, lambda { override_attr() { attr :new_value } } ].flatten! }

    it 'evaluates attributes' do 
      foo = mock.new(attrs)
    end

    it 'nested attrs' do
      foo = mock.new(nested_attrs)
    end
    it 'inherited attrs' do
      foo = mock.new(inherit_attrs)
    end
    it 'inherited nested attrs', wip: true do
      foo = mock.new(nested_inherit_attrs)
      binding.pry
    end
  end
end
