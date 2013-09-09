# coding: utf-8
require 'spec_helper'

describe Project do

  context 'route' do

    it 'raises a hint when not supplying any commands' do
      expect { Project.route(*%w[]) }.to raise_error Klipp::Hint
    end

    it 'raises an error when supplying an unknown command' do
      expect { Project.route(*%w[magic]) }.to raise_error RuntimeError
    end

    it 'routes init' do
      Project.expects(:cli_init).with(['Example'])
      Project.route(*%w[init Example])
    end

    it 'routes make' do
      Project.expects(:cli_make).with(['-f'])
      Project.route(*%w[make -f])
    end

  end

  context 'init' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'without template name raises error' do
      expect { Project.cli_init([]) }.to raise_error Klipp::Hint
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

  context 'make' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
      Dir.stubs(:pwd).returns(Dir.mktmpdir)

      maker = Project::Maker.new
      maker.eval_string(read_fixture('Klippfile'), fixture_path('Klippfile'))
      Project::Maker.stubs(:from_file).returns(maker)
    end

    it 'makes a new project' do

      Project.cli_make([])
      File.exists?(File.join Dir.pwd, 'Podfile').should be true
      File.exists?(File.join Dir.pwd, '.gitignore').should be true
      File.exists?(File.join Dir.pwd, 'AmazingApp').should be true
      File.exists?(File.join Dir.pwd, 'Example.klippspec').should be false

    end

  end

end