# coding: utf-8
require 'spec_helper'

describe Project do

  context 'when routing commands' do

    it 'raises an error when not supplying any commands' do
      expect { Project.route(*%w[]) }.to raise_error RuntimeError
    end

    it 'raises an error when supplying an unknown command' do
      expect { Project.route(*%w[magic]) }.to raise_error RuntimeError
    end

    it 'routes init' do
      Project.expects(:cli_init).with(['Example'])
      Project.route(*%w[init Example])
    end

  end

  context 'init from fixtures' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'without template name raises error' do
      expect { Project.cli_init([]) }.to raise_error RuntimeError
    end

    context 'without an existing Klippfile' do
      before do
        File.stubs(:exists?).returns(false)
      end

      it 'write a new Klippfile' do
        klippfile = read_fixture 'Klippfile-after-init'
        File.expects(:write).with('Klippfile', klippfile)
        Project.cli_init(%w[Example])
      end
    end


    context 'with an existing Klippfile' do

      before do
        File.stubs(:exists?).returns(true)
      end

      it 'will not overwrite' do
        File.expects(:write).never
        expect { Project.cli_init(%w[Example]) }.to raise_error RuntimeError
      end

      it 'will overwrite when forced' do
        klippfile = read_fixture 'Klippfile-after-init'
        File.expects(:write).with('Klippfile', klippfile)
        Project.cli_init(%w[Example -f])
      end

    end

  end

end