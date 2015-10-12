require 'spec_helper'
include Boundaries

class Foo < Boundary; end
Foo.define(:base) do
  attributes do
    attr1 :base_attr
    attr2 :base_attr
  end

  transients do
    can_do :a_thing
  end

  stubs(:get) do
    with(:bar).and_returns(:bar)
    with('get', 'hat').and_returns { can_do } 
  end
end

describe Boundary do
  it 'does stuff' do
    binding.pry
  end
end
