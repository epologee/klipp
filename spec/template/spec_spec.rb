require 'spec_helper'

describe Template::Spec do

  context 'with validation disabled' do
    before do
      Template::Spec.any_instance.stubs(:invalidate)
    end

    it 'yields on initialize' do
      expect { |probe| Template::Spec.new().spec 'Example', &probe }.to yield_control
    end

    it 'passes itself as a parameter on yield' do
      expect { |probe| Template::Spec.new().spec('Example', &probe) }.to yield_with_args(be_an_instance_of(Template::Spec))
    end

    it 'validates the spec after configuration' do
      spec = Template::Spec.new
      spec.expects(:validate)
      spec.spec('')
    end

    it 'raises an error when overwriting tokens, like the BLANK token' do
      (expect do
        Template::Spec.new().spec 'Example' do |spec|
          spec.token :BLANK do |t|
            t.comment = "You can't overwrite tokens"
          end
        end
      end).to raise_error RuntimeError
    end
  end

  context 'with an invalid spec' do

    before do
      @spec = Template::Spec.new
    end

    it 'invalidates' do
      @spec.expects(:invalidate)
      @spec.spec('')
    end

    it 'raises an error when invalidating' do
      expect { @spec.spec('') }.to raise_error RuntimeError
    end

  end

  context 'with a valid spec' do

    before do
      @template = Template::Spec.new
      @template.spec('Example') { }
    end

    it 'has a name' do
      @template.name = 'Project X'
      @template.name.should eq 'Project X'
    end

    it 'has a post-action' do
      @template.post_action = 'pod install'
      @template.post_action.should eq 'pod install'
    end

    it 'has a token hash' do
      @template[:PROJECT_ID] = Template::Token.new
      @template[:PROJECT_ID].should be_an_instance_of(Template::Token)
    end

    it 'creates a token' do
      yielded_token = :not_a_token
      @template.token(:PROJECT_ID) { |t| yielded_token = t }
      yielded_token.should be_an_instance_of Template::Token
    end

    it 'has a blank token' do
      @template[:BLANK].hidden.should eq true
      @template[:BLANK].value.should eq ''
    end

    it 'has a date token' do
      @template[:DATE].hidden.should eq true
      @template[:DATE].value.should eq DateTime.now.strftime('%F')
    end

    it 'has a year token' do
      @template[:YEAR].hidden.should eq true
      @template[:YEAR].value.should eq '2013'
    end

  end

  context 'when loading a klippspec' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(File.dirname(__dir__), 'fixtures'))
    end

    context 'with an invalid klippspec' do

      it 'raises an error when loading an invalid klippspec' do
        klippspec = File.join(Klipp::Configuration.root_dir, 'template-repository', 'BadExample', 'BadExample.klippspec')
        File.exists?(klippspec).should be true
        expect { Template::Spec.from_file(klippspec) }.to raise_error RuntimeError
      end

    end

    context 'with a valid klippspec' do

      before do
        @path = File.join(Klipp::Configuration.root_dir, 'template-repository', 'Example', 'Example.klippspec')
        File.exists?(@path).should be true
      end

      it 'loads a spec from a file' do
        Template::Spec.from_file(@path).should be_an_instance_of Template::Spec
      end

      it 'generates a project specific Klippfile' do
        spec = Template::Spec.from_file(@path)
        fixture = read_fixture 'Klippfile-after-init'
        spec.klippfile.should eq fixture
      end

    end

  end


end
