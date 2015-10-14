describe Mock do
  let(:mock) { Mock }
  describe 'setting attributes' do

    let(:attrs) { [ lambda { attr1 :base; attr2 :base } ] }
    let(:nested_attrs) { [ lambda { attr1 :base; attr2() { attr1 :base; attr2 :base  } } ] }
    let(:inherit_attrs) { [ lambda { attr1 :base; attr2 :base }, lambda { attr2 :new_value; attr3 :new_value } ] }
    let(:nested_inherit_attrs) { [
                                   lambda { attr1 :base; attr2() { attr1 :base; attr2 :base  } },
                                   lambda { attr2() { attr1 :new_value } }
    ] }

    it 'evaluates attributes' do
      foo = mock.new(attrs, {}, [], [], Boundary)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 => :base } )
    end

    it 'nested attrs' do
      foo = mock.new(nested_attrs, {}, [], [], Boundary)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 => { attr1: :base, attr2: :base } } )
    end
    it 'inherited attrs' do
      foo = mock.new(inherit_attrs, {}, [], [], Boundary)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 => :new_value, :attr3 => :new_value } )
    end
    it 'inherited nested attrs' do
      foo = mock.new(nested_inherit_attrs, {}, [], [], Boundary)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 =>  { :attr1 => :new_value, :attr2 => :base } } )
    end
  end

  describe 'setting stubs' do
    before(:each) { MethodStub.send(:public, *MethodStub.private_instance_methods) }

    let(:put) { { :put => [ lambda { with :bat } ] } } 
    let(:get) { { :get => [ lambda { with :search; with :bar }, lambda { with :foo } ] } }

    let(:get_with_return) { { :get => [ lambda { with(:search).and_returns {}  } ] } }

    it 'evaluates attributes' do
      foo = Mock.new([], put, [], [], Boundary )
      expect(foo.stubs[:put]).to all(be_a(MethodStub))
    end

    it 'multiple stubs' do
      foo = Mock.new([], put.merge(get))
      expect(foo.stubs.values.flatten).to all(be_a(MethodStub))
    end
  end

end
