# coding: utf-8
require 'spec_helper'

describe Klipp::Maker do

  it 'stores values for template tokens' do
    maker = Klipp::Maker.new()
    maker.tokens[:PROJECT_ID] = 'A project id'
    maker.tokens[:PROJECT_ID].should eq 'A project id'
  end

  context 'concerning klippfiles' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(File.dirname(__dir__), 'fixtures'))
      File.directory?(Klipp::Configuration.root_dir).should be true
    end

    context 'when loading' do

      context 'a minimal klippfile' do

        it 'validates' do
          maker = Klipp::Maker.new()
          maker.expects(:invalidate).never

          path = fixture_path('Klippfile-minimal')
          string = read_fixture('Klippfile-minimal')
          maker.eval_string(string, path)
        end

      end

      context 'an invalid klippfile' do

        it "raises an error if it's bad ruby" do
          maker = Klipp::Maker.new()
          maker.expects(:invalidate).never

          path = fixture_path('Klippfile-bad-ruby')
          string = read_fixture('Klippfile-bad-ruby')
          expect { maker.eval_string(string, path) }.to raise_error RuntimeError
        end

        it "raises an error the Klippfile doesn't exist" do
          File.stubs(:exists?).returns false
          expect { Klipp::Maker.from_file ('anywhere/Klippfile') }.to raise_error RuntimeError
        end

        it 'warns about unambiguous templates' do
          maker = Klipp::Maker.new()
          path = fixture_path('Klippfile-unambiguous')
          string = read_fixture('Klippfile-unambiguous')
          expect { maker.eval_string(string, path) }.to raise_error Klipp::Hint
        end

        it 'raises an error for unknown templates' do
          maker = Klipp::Maker.new()
          expect { maker.eval_string("create 'Amnesia'", 'fictional-klippspec.rb') }.to raise_error RuntimeError
        end

        it 'raises an error for empty templates' do
          maker = Klipp::Maker.new()
          expect { maker.eval_string("create ''", 'fictional-klippspec.rb') }.to raise_error RuntimeError
        end
      end

      context 'a valid klippfile' do

        it 'inits from a klippfile' do
          Klipp::Maker.from_file(fixture_path('Klippfile')).should be_an_instance_of Klipp::Maker
        end

        it 'validates ambiguous templates' do
          maker = Klipp::Maker.new()
          maker.expects(:invalidate).never
          path = fixture_path('Klippfile-ambiguous')
          string = read_fixture('Klippfile-ambiguous')
          maker.eval_string(string, path)
        end

      end

    end

  end

end