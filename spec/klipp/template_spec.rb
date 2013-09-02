require 'spec_helper'

describe Klipp::Template do

  it 'raises an error when initialized with an invalid path or name' do
    expect {
      Klipp::Template.new('bull', 'shit')
    }.to raise_error(RuntimeError)
  end

  context 'with a valid path and name' do

    before do
      @templates_dir = File.join(__dir__, '..', 'fixtures', 'templates')
      @klipps_dir = File.join(__dir__, '..', 'fixtures', 'klipps')
    end

    it 'initializes' do
      Klipp::Template.new(@templates_dir, 'Example').should be_a Klipp::Template
    end

    context 'with a template object' do

      before do
        @template = Klipp::Template.new(@templates_dir, 'Example')
      end

      it 'knows the name of the corresponding .klippfile' do
        @template.klippfile.should eq 'Example.klippfile'
      end

      it 'can generate stubbed contents for a .klippfile' do
        @template.generated_klippfile.should eq File.read(File.join(@klipps_dir,'Generated.klippfile'))
      end

      it 'contains a matching number of tokens' do
        @template.tokens.should have_exactly(4).items
      end

      it 'loads the token values from a valid Klippfile' do
        @template.load_klippfile File.join(@klipps_dir, 'Example.klippfile')
        @template.value_for_token('PARTNER').should eq 'The Prestigeous Partner'
      end

      it 'raises an error when the Klippfile is malformed' do
        expect { @template.load_klippfile File.join(@klipps_dir, 'MalformedExample.klippfile') }.to raise_error RuntimeError
      end

      it 'raises an error when the Klippfile contains excess tokens' do
        expect { @template.load_klippfile File.join(@klipps_dir, 'ExcessiveExample.klippfile') }.to raise_error RuntimeError
      end

      it 'raises an error when the Klippfile contains too few tokens' do
        expect { @template.load_klippfile File.join(@klipps_dir, 'LackingExample.klippfile') }.to raise_error RuntimeError
      end

    end

  end

end