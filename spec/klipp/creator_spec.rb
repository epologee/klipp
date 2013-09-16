# coding: utf-8
require 'spec_helper'

describe Klipp::Creator do

  it 'stores values for template tokens' do
    creator = Klipp::Creator.new()
    creator.tokens[:PROJECT_ID] = 'A project id'
    creator.tokens[:PROJECT_ID].should eq 'A project id'
  end

  context 'concerning klippfiles' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(File.dirname(__dir__), 'fixtures'))
      File.directory?(Klipp::Configuration.root_dir).should be true
    end

    context 'from file' do

      context 'a minimal klippfile' do

        it 'validates' do
          creator = Klipp::Creator.new()
          creator.expects(:invalidate).never

          path = fixture_path('Klippfile-minimal')
          string = read_fixture('Klippfile-minimal')
          creator.eval_string(string, path)
        end

      end

      context 'an invalid klippfile' do

        it "raises an error if it's bad ruby" do
          creator = Klipp::Creator.new()
          creator.expects(:invalidate).never

          path = fixture_path('Klippfile-bad-ruby')
          string = read_fixture('Klippfile-bad-ruby')
          expect { creator.eval_string(string, path) }.to raise_error RuntimeError
        end

        it "raises an error the Klippfile doesn't exist" do
          File.stubs(:exists?).returns false
          expect { Klipp::Creator.from_file ('anywhere/Klippfile') }.to raise_error RuntimeError
        end

        it 'warns about unambiguous templates' do
          creator = Klipp::Creator.new()
          path = fixture_path('Klippfile-unambiguous')
          string = read_fixture('Klippfile-unambiguous')
          expect { creator.eval_string(string, path) }.to raise_error Klipp::Hint
        end

        it 'raises an error for unknown templates' do
          creator = Klipp::Creator.new()
          expect { creator.eval_string("create 'Amnesia'", 'fictional-klippspec.rb') }.to raise_error RuntimeError
        end

        it 'raises an error for empty templates' do
          creator = Klipp::Creator.new()
          expect { creator.eval_string("create ''", 'fictional-klippspec.rb') }.to raise_error RuntimeError
        end
      end

      context 'a valid klippfile' do

        it 'initializes from a klippfile' do
          Klipp::Creator.from_file(fixture_path('Klippfile')).should be_an_instance_of Klipp::Creator
        end

        it 'validates ambiguous templates' do
          creator = Klipp::Creator.new()
          creator.expects(:invalidate).never
          path = fixture_path('Klippfile-ambiguous')
          string = read_fixture('Klippfile-ambiguous')
          creator.eval_string(string, path)
        end

      end

    end

    context 'from user input' do

      before do
        @input    = StringIO.new
        @output   = StringIO.new
        @highline = HighLine.new(@input, @output)
      end

      it 'validates' do
        creator = Klipp::Creator.new()
        creator.expects(:invalidate).never

        @input << "Object\n"
        @input.rewind

        creator.ask_user_input('Interactive', @highline)
      end

    end

  end


end