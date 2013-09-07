require 'spec_helper'

describe Template::Spec do

  it 'yields on initialize' do
    expect { |probe| Template::Spec.new &probe }.to yield_control
  end

  it 'raises an error when initialized without a block' do
    expect { Template::Spec.new }.to raise_error RuntimeError
  end

  it 'passes itself as a parameter on yield' do
    expect { |probe| Template::Spec.new &probe }.to yield_with_args(be_an_instance_of(Template::Spec))
  end

  it 'validates the spec after configuration' do
    Template::Spec.any_instance.expects(:validate)
    Template::Spec.new {}
  end

  context 'with a spec' do

    before do
      @template = Template::Spec.new {}
    end

    it 'has a name' do
      @template.name = 'Project X'
      @template.name.should eq 'Project X'
    end

    it 'has a token hash' do
      @template['PROJECT_ID'] = Template::Token.new('PROJECT_ID')
      @template['PROJECT_ID'].should be_an_instance_of(Template::Token)
    end

    it 'creates a token by name' do
      yielded_token = :not_a_token
      @template.token('PROJECT_ID') { |t| yielded_token = t }
      yielded_token.name.should eq 'PROJECT_ID'
    end

    it 'configures a token in a block' do
      yielded_token = :not_a_token
      @template.token('PROJECT_ID') { |t|
        yielded_token = t
      }
      yielded_token.name.should eq 'PROJECT_ID'
    end

  end

end
