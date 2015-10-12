require 'spec_helper'
require 'json'
class Interface
  def self.get(arg)
    case arg
    when :foo1
      { attr1: :foo, attr2: :bar, attr3: :batz }
    when :foo2
      :foo2
    else
      false
    end
  end
end

class MockInterface
  def self.stub(m, kwargs)

  end

  def self.get(kwargs, blk)
  end
end

class Foo
  @interface = Interface
  def self.get(arg = nil)
    @interface.get(arg)
  end
end

class FooBoundary < Boundaries::Boundary
    TARGET = Foo

    @interface  = MockInterface.new

    def self.includes(actual, expected)
      expect(actual).to include(expected)
    end

    class_interface do |m, *args, &blk|
      #Faraday::Adapters::Test::Stub.new(kwargs, &blk)
    end
    def self.foo_class_method(arg)
      binding.pry
    end
end

class BarBoundary < Boundaries::Boundary
end



describe Boundaries do
  before(:each) do
    FooBoundary.clear

    FooBoundary.define :foo1 do

      attributes do
        attr1 :foo
        attr2 :bar
        attr3 :batz
      end
      
      transient do
        org_admin? 'true'
      end
      
      stubs(:get, 'orgAdmin', { foo: bar }).and_returns(:org_admin?).with_marshal(:to_response)

      stubs(:get, :foo, [1], { foo: :bar}).and_returns(:self, :to_json).and_validates(:includes)
    end
  end

  let(:foo1) { FooBoundary.class_eval { @defined[:foo1] } }
  let(:foo2) { FooBoundary.class_eval { @defined[:foo2] } }


  before(:all) do
    @foo2 = lambda { |&blk|
      FooBoundary.define(:foo2, extends: :foo1) do
        instance_exec(&blk)
        self
      end
    }
  end

  it 'has a version number' do
    expect(Boundaries::VERSION).not_to be nil
  end

  it 'you can add mocks' do
    expect(FooBoundary.value_of(:foo1, :json_response)).to eq( { attr1: :foo, attr2: :bar, attr3: :batz })
  end

  it 'mock instances are not shared between subclasses' do
    expect { BarBoundary.value_of(:foo1, :json_response) }.to raise_error(Boundaries::BoundaryUndefined)
  end

  it 'can mock' do
    FooBoundary.mock(:foo1)
    #expect(Foo.get).to eq(FooBoundary.value_of(:foo1, :json_response))
  end

  it 'is it unmocked' do
    expect(Foo.get).to be false
  end

  describe 'validating' do
    it 'validates' do
      FooBoundary.validate(foo1)
    end
  end

  describe 'extending' do
    describe 'inerhits' do
      before(:each) { @foo2.call {} }

      it 'attributes' do
        expect(foo2.return_value(:json_response)).to eq(foo1.return_value(:json_response))
      end

      it 'accepts' do
        expect(foo2.stubbed_methods).to eq(foo1.stubbed_methods)
      end

      it 'validates' do
        expect(foo2.validates).to eq(foo1.validates)
      end

      it 'validate_strategy' do
        expect(foo2.validate_strategy).to eq(foo1.validate_strategy)
      end

      it 'mocks' do
        expect(foo2.meth).to eq(foo1.meth)
      end
    end

    describe 'overriding' do
      it 'attributes' do
        @foo2.call  do
          #returns(:json_response) { attr1 :foo2 }
        end
        expected = foo1.return_value(:json_response)
        expected[:attr1] = :foo2
        expect(foo2.return_value(:json_response)).to eq(expected)
      end

      it 'stubs' do
        @foo2.call do
          stubs :get, :foo2
        end
        #expect(foo2.stubbed_methods).to eq({:get => :foo2 } )
      end

      it 'validates' do
        @foo2.call do
          validates false
        end
        expect(foo2.validates).to eq(false)
      end

      it 'validates_strategy' do
        @foo2.call do
          validates :custom
        end
        expect(foo2.validate_strategy).to eq(:custom)
      end

      it 'mocks' do
        @foo2.call do
          mocks :post
        end
        expect(foo2.meth).to eq(:post)
      end
    end

  end

  it 'runs tests against mocked values' do
    #FooBoundary.run_tests
  end
end
