require 'spec_helper'

class Foo
  def self.get()
    false
  end
end

class FooBoundary < Boundaries::Boundary
  DEFAULT_HASH = { name: :foo }
  MOCKS = Foo
end


class BarBoundary < Boundaries::Boundary
  DEFAULT_HASH = { name: :bar }
end

FooBoundary.define(:foo1) do 
  mocks :get
  accepts /arg1/
  returns ({ name: :foo1 })
  validates true
end


describe Boundaries do

  it 'has a version number' do
    expect(Boundaries::VERSION).not_to be nil
  end

  it 'you can add mocks' do

    expect(FooBoundary.value_of(:foo1)).to eql({ name: :foo1 })
  end

  it 'mock instances are not shared between subclasses' do
    expect { BarBoundary.value_of(:foo1) }.to raise_error(Boundaries::BoundaryUndefined)
  end
  
  it 'can mock' do
    FooBoundary.mock(:foo1)
    expect(Foo.get).to be true 
  end
end
