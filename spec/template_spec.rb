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

    it 'routes spec' do
      Template.expects(:cli_spec)
      Template.route(*%w[spec])
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

  context 'spec' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'raises a hint without a template name' do
      expect { Template.cli_spec(%w[]) }.to raise_error Klipp::Hint
    end

    it 'raises an error if the template name is malformed' do
      expect { Template.cli_spec(['No.dots']) }.to raise_error RuntimeError
      expect { Template.cli_spec(['No w&ird characters']) }.to raise_error RuntimeError
      expect { Template.cli_spec(['No w&ird characters!']) }.to raise_error RuntimeError
    end

    it 'specs a .klippspec, like Empty.klippspec' do
      File.expects(:write).with(File.join(Dir.pwd, 'Empty.klippspec'), read_fixture('Empty.klippspec'))
      Template.cli_spec(%w[Empty])
    end

    it 'does not overwrite klippspecs' do
      File.expects(:write).never
      File.stubs(:exists?).returns(true)
      Template.cli_spec(%w[Empty])
    end

    it 'will overwrite klippspecs when forced' do
      File.expects(:write).with(File.join(Dir.pwd, 'Empty.klippspec'), read_fixture('Empty.klippspec'))
      File.stubs(:exists?).returns(true)
      Template.cli_spec(%w[Empty -f])
    end

  end

end