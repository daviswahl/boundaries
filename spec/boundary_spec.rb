require 'spec_helper'
include Boundaries

class Foo
  def self.get
    :unmodified
  end

  def get
    :unmodified
  end
end
class FooBoundary < Boundary
 target Foo 

 def self.can_do(arg)
   "#{arg} caaan do"  
 end
end

FooBoundary.define(:base) do
  attributes do
    attr1 :base_attr
    attr2 :base_attr
  end

  transients do
    can_do :a_thing
  end

  instance_stub(:get) do
    with(:bar).and_returns(:bar)
  end
  
  class_stub(:get) do
    with.and_returns(:bar)
    with(:bar).and_returns(:bar)
    with('get', 'hat').and_returns('hat') { |h| can_do(h) } 
    with(:attrs).and_returns(attributes, &:format_attrs) 
  end
end

describe Boundary do
  it 'does stuff' do
    b = FooBoundary.get(:base)
    b.mock!
    #expect(Foo.get(:bar)).to eq(:bar)
    expect(Foo.get('get', 'hat')).to eq('hat caaan do')
    #expect(Foo.new.get).to eq(:unmodified)
    #expect(Foo.new.get(:bar)).to eq(:bar)
  end

  it 'does stuff' do
    #expect(Foo.get).to eq(:unmodified)
  end
end
