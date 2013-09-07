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
      Project.expects(:cli_init).with('Example')
      Project.route(*%w[init Example])
    end

  end

end