# coding: utf-8
require 'spec_helper'

describe Template do

  context 'when routing commands' do

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

  end

  context 'when listing' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(__dir__, 'fixtures'))
    end

    it 'routes list' do
      Template.expects(:cli_list)
      Template.route(*%w[list])
    end

    it 'lists the available templates, like Example' do
      Template.list.should include({ name: 'Example', repo: 'template-repository' })
    end

  end

end