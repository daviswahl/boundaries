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
      foo = mock.new(attrs)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 => :base } )
    end

    it 'nested attrs' do
      foo = mock.new(nested_attrs)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 => { attr1: :base, attr2: :base } } )
    end
    it 'inherited attrs' do
      foo = mock.new(inherit_attrs)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 => :new_value, :attr3 => :new_value } )
    end
    it 'inherited nested attrs', wip: true do
      foo = mock.new(nested_inherit_attrs)
      expect(foo.attributes).to eq( { :attr1 => :base, :attr2 =>  { :attr1 => :new_value, :attr2 => :base } } )
    end
  end
end
