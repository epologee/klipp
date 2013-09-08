# coding: utf-8
require 'spec_helper'

describe Project do

  context 'when routing commands'  do

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

    it 'creates a Klippfile' do
      klippfile = read_fixture 'Klippfile-after-init'
      File.expects(:write).with('Klippfile', klippfile)
      Project.cli_init(%w[Example])
    end

  end

  context 'init from ~/.klipp' do

    it 'works' do
      klippfile = read_fixture 'Klippfile-after-init'
      File.expects(:write).with('Klippfile', klippfile)
      Project.cli_init(%w[Example])
    end

  end

end