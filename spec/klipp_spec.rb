# coding: utf-8
require 'spec_helper'

describe Klipp do

  before do
    @output = Klipp.output = StringIO.new
  end

  describe 'when routing' do

    it 'prints help without any parameters' do
      expect { Klipp.route *%w[] }.to raise_error SystemExit
      should include 'Xcode templates for the rest of us.'
    end

    it 'routes `prepare`' do
      Klipp.expects(:prepare)
      Klipp.route *%w[prepare Example]
    end

    it 'prints help when preparing without a template name' do
      expect { Klipp.route *%w[prepare] }.to raise_error SystemExit
      should include 'Add a template name to the `prepare` command.'
    end

    it 'routes `list`' do
      Klipp.expects(:list)
      Klipp.route *%w[list]
    end

  end

  describe 'when preparing' do

    it 'raises help if the template argument is missing' do
      expect { Klipp.prepare %w[] }.to raise_error HelpRequest
    end

  end

  describe 'when listing' do

    it 'lists templates' do
      Klipp::Configuration.stubs(:root_dir).returns File.join(__dir__, 'fixtures')
      Klipp.list
      should include 'Example'
    end

  end

  def subject
    @output.string
  end

end