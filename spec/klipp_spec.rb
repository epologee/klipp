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

    it 'routes project with exit code 0' do
      Project.expects(:route)
      Klipp.route(*%w[project]).should eq 0
    end

    it 'routes template with exit code 0' do
      Template.expects(:route)
      Klipp.route(*%w[template]).should eq 0
    end

  end


end