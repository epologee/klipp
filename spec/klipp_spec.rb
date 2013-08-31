# coding: utf-8
require 'spec_helper'

describe Klipp do

  describe 'Project' do

    it 'runs commands' do

      Klipp::Command.run(ARGV << 'project new Example')

    end

  end

end