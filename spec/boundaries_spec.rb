require 'spec_helper'

class Foo
  def self.get()
    false
  end
end
class FooBoundary < Boundaries::Boundary
    TARGET = Foo
    mock_attributes :attr1, :attr2, :attr3
end

class BarBoundary < Boundaries::Boundary
end



describe Boundaries do
  before(:each) do
    FooBoundary.clear

    FooBoundary.define :foo1 do
      mocks :get

      accepts /arg1/

      returns do
        attr1 :foo
        attr2 :bar
        attr3 :batz
      end
      validates :includes
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
    FooBoundary.prepare(self)
  end

  it 'has a version number' do
    expect(Boundaries::VERSION).not_to be nil
  end

  it 'you can add mocks' do
    expect(FooBoundary.value_of(:foo1)).to eq({ attr1: :foo, attr2: :bar, attr3: :batz })
  end

  it 'mock instances are not shared between subclasses' do
    expect { BarBoundary.value_of(:foo1) }.to raise_error(Boundaries::BoundaryUndefined)
  end

  it 'can mock' do
    FooBoundary.mock(:foo1)
    expect(Foo.get).to eq(FooBoundary.value_of(:foo1))
  end

  it 'is it unmocked' do
    expect(Foo.get).to be false
  end

  describe 'extending' do
    describe 'inerhits' do
      before(:each) { @foo2.call {} }

      it 'attributes' do
        expect(foo2.to_value).to eq(foo1.to_value)
      end

      it 'accepts' do
        expect(foo2.get_accepts).to eq(foo1.get_accepts)
      end

      it 'validates' do
        expect(foo2.get_validates).to eq(foo1.get_validates)
      end

      it 'validate_strategy' do
        expect(foo2.get_validate_strategy).to eq(foo1.get_validate_strategy)
      end

      it 'mocks' do
        expect(foo2.get_meth).to eq(foo1.get_meth)
      end

    end

    describe 'overriding' do
      it 'attributes' do
        @foo2.call  do
          returns { attr1 :foo2 }
        end
        expected = foo1.to_value
        expected[:attr1] = :foo2
        expect(foo2.to_value).to eq(expected)
      end

      it 'accepts' do
        @foo2.call do
          accepts /foo2/
        end
        expect(foo2.get_accepts).to eq(/foo2/)
      end

      it 'validates', wip: true do
        @foo2.call do
          validates false
        end
        expect(foo2.get_validates).to eq(false)
      end

      it 'validates_strategy' do
        @foo2.call do
          validates :custom
        end
        expect(foo2.get_validate_strategy).to eq(:custom)
      end

      it 'mocks' do
        @foo2.call do
          mocks :post
        end
        expect(foo2.get_meth).to eq(:post)
      end


    end

  end

  it 'runs tests against mocked values' do
    #FooBoundary.run_tests
  end
end
