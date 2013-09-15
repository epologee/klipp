# coding: utf-8
require 'spec_helper'

describe Klipp do

  context 'capturing stdout' do

    it 'matches stdout' do
      capture_stdout {
        puts "I'm out"
      }.should eq "I'm out\n"
    end

    it 'matches formatador stdout' do
      capture_stdout {
        Formatador.display_line "I'm [green]green[/]"
      }.should include "green"
    end

  end

  context 'when routing commands' do

    it 'returns exit code 1 without any commands and displays a hint' do
      (capture_stdout do
        Klipp.route(*%w[]).should eq 1
      end).should include '[?]'
    end

    it 'returns exit code 1 with an unknown command and displays the error' do
      (capture_stdout do
        Klipp.route(*%w[magic]).should eq 1
      end).should include '[!]'
    end

    it 'routes init' do
      Klipp.expects(:cli_init).with(['Example'])
      Klipp.route(*%w[init Example])
    end

    it 'routes make' do
      Klipp.expects(:cli_make).with(['-f'])
      Klipp.route(*%w[make -f])
    end

    it 'routes template with exit code 0' do
      Template.expects(:route)
      Klipp.route(*%w[template]).should eq 0
    end

  end

  context 'init' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'without template name raises error' do
      expect { Klipp.cli_init([]) }.to raise_error Klipp::Hint
    end

    context 'without an existing Klippfile' do
      before do
        File.stubs(:exists?).returns(false)
      end

      it 'write a new Klippfile' do
        klippfile = read_fixture 'Klippfile-after-init'
        File.expects(:write).with('Klippfile', klippfile)
        Klipp.cli_init(%w[Example])
      end
    end


    context 'with an existing Klippfile' do

      before do
        File.stubs(:exists?).returns(true)
      end

      it 'will not overwrite' do
        File.expects(:write).never
        expect { Klipp.cli_init(%w[Example]) }.to raise_error RuntimeError
      end

      it 'will overwrite when forced' do
        klippfile = read_fixture 'Klippfile-after-init'
        File.expects(:write).with('Klippfile', klippfile)
        Klipp.cli_init(%w[Example -f])
      end

    end

  end

  context 'make' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
      Dir.stubs(:pwd).returns(Dir.mktmpdir)

      maker = Klipp::Maker.new
      maker.eval_string(read_fixture('Klippfile'), fixture_path('Klippfile'))
      Klipp::Maker.stubs(:from_file).returns(maker)
    end

    it 'makes a new project' do

      Klipp.cli_make([])
      File.exists?(File.join Dir.pwd, 'Podfile').should be true
      File.exists?(File.join Dir.pwd, '.gitignore').should be true
      File.exists?(File.join Dir.pwd, 'AmazingApp').should be true
      File.exists?(File.join Dir.pwd, 'Example.klippspec').should be false

    end

  end

end