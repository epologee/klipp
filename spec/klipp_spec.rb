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

    it 'prints warnings accordingly' do
      expect { Klipp.route *%w[prepare Bullshit] }.to raise_error SystemExit
      should include '[!]'
    end

    it 'raises a warning when routing unknown commands' do
      expect { Klipp.route *%w[allyourbase] }.to raise_error SystemExit
      should include '[!]'
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

    it 'routes `version`' do
      Klipp.expects(:version)
      Klipp.route *%w[version]
    end

    it 'routes `create``' do
      Klipp.expects(:create)
      Klipp.route *%w[create]
    end

  end

  describe 'when preparing' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns File.join(__dir__, 'fixtures')
    end

    it 'raises help if the template argument is missing' do
      expect { Klipp.prepare nil }.to raise_error HelpRequest
    end

    it 'saves a klippfile' do
      IO.expects(:write).with('Example.klippfile', anything).once
      Klipp.prepare 'Example'
    end

    it 'raises an error when the template argument is incorrect' do
      expect { Klipp.prepare 'Bullshit' }.to raise_error RuntimeError
    end

    it 'raises an error when a .klippfile for the template already exists' do
      File.stubs(:exists?).with(anything).returns true
      expect { Klipp.prepare 'Example' }.to raise_error RuntimeError
    end

  end

  describe 'when listing' do

    it 'lists templates' do
      Klipp::Configuration.stubs(:root_dir).returns File.join(__dir__, 'fixtures')
      Klipp.list
      should include 'Example'
    end

    it 'raises an error when there are no templates' do
      Klipp.expects(:template_files).returns([])
      expect { Klipp.list }.to raise_error RuntimeError
    end

  end

  describe 'when versioning' do

    it 'displays the current version' do
      Klipp.version
      should include Klipp::VERSION
    end

  end

  def subject
    @output.string
  end

end