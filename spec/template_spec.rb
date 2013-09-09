# coding: utf-8
require 'spec_helper'

describe Template do

  context 'route' do

    it 'raises a hint when not supplying any commands' do
      expect { Template.route(*%w[]) }.to raise_error Klipp::Hint
    end

    it 'raises an error when supplying an unknown command' do
      expect { Template.route(*%w[magic]) }.to raise_error RuntimeError
    end

    it 'routes list' do
      Template.expects(:cli_list)
      Template.route(*%w[list])
    end

    it 'routes init' do
      Template.expects(:cli_init)
      Template.route(*%w[init])
    end

  end

  context 'list' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'lists the available templates, like Example' do
      capture_stdout {
        Template.cli_list
      }.should include 'Example', 'template-repository'
    end

  end

  context 'init' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'raises a hint without a template name' do
      expect { Template.cli_init(%w[]) }.to raise_error Klipp::Hint
    end

    it 'raises an error if the template name is malformed' do
      expect { Template.cli_init(['No.dots']) }.to raise_error RuntimeError
      expect { Template.cli_init(['No w&ird characters']) }.to raise_error RuntimeError
      expect { Template.cli_init(['No w&ird characters!']) }.to raise_error RuntimeError
    end

    it 'inits a .klippspec, like Empty.klippspec' do
      File.expects(:write).with(File.join(Dir.pwd, 'Empty.klippspec'), read_fixture('Empty.klippspec'))
      Template.cli_init(%w[Empty])
    end

    it 'does not overwrite klippspecs' do
      File.expects(:write).never
      File.stubs(:exists?).returns(true)
      Template.cli_init(%w[Empty])
    end

    it 'will overwrite klippspecs when forced' do
      File.expects(:write).with(File.join(Dir.pwd, 'Empty.klippspec'), read_fixture('Empty.klippspec'))
      File.stubs(:exists?).returns(true)
      Template.cli_init(%w[Empty -f])
    end

  end

end