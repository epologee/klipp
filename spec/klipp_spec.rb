# coding: utf-8
require 'spec_helper'

describe Klipp do

  before do
    @output = Klipp.output = StringIO.new
  end

  describe 'when routing' do

    it 'prints help without any parameters' do
      expect { Klipp.route *%w[] }.to raise_error SystemExit
      @output.string.should include 'Xcode templates for the rest of us.'
    end

    it 'routes `prepare`' do
      Klipp.expects(:prepare)
      Klipp.route *%w[prepare Example]
    end

    it 'prints help when preparing without a template name' do
      expect { Klipp.route *%w[prepare] }.to raise_error SystemExit
      @output.string.should include 'Add a template name to the `prepare` command.'
    end

  end

  describe 'when preparing' do

    it 'raises help if the template argument is missing' do
      expect { Klipp.prepare %w[] }.to raise_error HelpRequest
    end

  end

end
