require 'spec_helper'

describe Template::Spec do

  context 'identifier methods' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(File.dirname(__dir__), 'fixtures'))
    end

    it 'finds the path to a template name' do
      path = Template::Spec.spec_path_for_identifier('Example')
      path.should eq File.join(File.dirname(__dir__), 'fixtures', 'template-repository', 'Example', 'Example.klippspec')
    end

    it 'raises error if a template doesn\'t exist' do
      expect { Template::Spec.spec_path_for_identifier('Non-existing') }.to raise_error RuntimeError
    end

    it 'knows about unambiguous specs' do
      Template::Spec.identifier_is_ambiguous('Ambiguous').should eq false
    end

    it 'raises error if a template is unambiguous' do
      expect { Template::Spec.spec_path_for_identifier('Ambiguous') }.to raise_error RuntimeError, /Found multiple templates/
    end

    it 'finds the path to a template in a specific repo' do
      path = Template::Spec.spec_path_for_identifier('template-repository/Ambiguous')
      path.should eq File.join(File.dirname(__dir__), 'fixtures', 'template-repository', 'Ambiguous', 'Ambiguous.klippspec')
    end

    it 'deducts the template identifier from an unambiguous template name' do
      path = Template::Spec.spec_path_for_identifier 'Example'
      hash = Template::Spec.hash_for_spec_path path
      Template::Spec.hash_to_identifier(hash).should eq 'template-repository/Example'
    end

  end

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
      spec.expects(:validate_spec)
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

    it 'rescues and re-raises errors from the config block' do
      expect { @spec.spec('Example') { |s| s.lala = 5 } }.to raise_error RuntimeError, /Invalid klippspec configuration/
    end

    it 'raises errors from klippspec string' do
      expect { @spec.from_string('lalala', 'fake/path') }.to raise_error RuntimeError, /Error evaluating spec/
    end

  end

  context 'with a valid spec' do

    before do
      @template = Template::Spec.new
      @template.spec('Example') {}
    end

    it 'has a name' do
      @template.identifier = 'repo/ProjectX'
      @template.identifier.should eq 'repo/ProjectX'
    end

    it 'has a post-action setter' do
      @template.post_action = 'pod install'
      @template.post_actions.should eq ['pod install']
    end

    it 'has a post-actions setter' do
      @template.post_actions = ['git init', 'git add .', 'git commit -m "Initial commit."', 'pod install']
      @template.post_actions.should eq ['git init', 'git add .', 'git commit -m "Initial commit."', 'pod install']
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

        @spec = Template::Spec.from_file(@path)
      end

      it 'loads a spec from a file' do
        @spec.should be_an_instance_of Template::Spec
      end

      it 'generates a project specific Klippfile' do
        fixture = read_fixture 'Klippfile-after-init'
        @spec.klippfile.should eq fixture
      end

      it 'references the repo in the Klippfile' do
        @spec.klippfile.should include 'template-repository/Example'
      end

      context 'with a values hash' do
        before do
          @values = Hash.new
          @values[:PROJECT_ID] = "Klipp"
          @values[:PROJECT_TITLE] = "Templates for the rest of us"
          @values[:BUNDLE_ID] = "com.epologee.klipp"
          @values[:ORGANIZATION_NAME] = "epologee"
          @values[:CLASS_PREFIX] = "KLP"
        end

        it 'validates token values' do
          @spec.set_token_values @values
        end

        it 'replaces delimited tokens with its values' do
          @spec.set_token_values @values
          source = 'XXPROJECT_IDXX - XXPROJECT_TITLEXX - XXBUNDLE_IDXX - XXORGANIZATION_NAMEXX - XXCLASS_PREFIXXX'
          target = 'Klipp - Templates for the rest of us - com.epologee.klipp - epologee - KLP'
          @spec.replace_tokens(source).should eq target
        end
      end


    end

  end

  context 'when creating a klippspec' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(File.dirname(__dir__), 'fixtures'))
    end

    it 'generates the klippspec' do
      spec = Template::Spec.new
      spec.identifier = 'Example'
      spec.klippspec.should eq read_fixture('Empty.klippspec')
    end

  end

end
