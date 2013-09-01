require 'spec_helper'
require 'klipp/version'
require 'klipp/buffered_output'

describe Klipp::Command do

  before do
    Klipp::Command.output = @output = StringIO.new
  end

  it 'has a help banner' do
    Klipp::Command.banner.should include 'project'
  end

  it 'has help options' do
    @output.puts(Klipp::Command.options)
    @output.string.should include '--help'
    @output.string.should include '--version'
  end

  it 'prints the version number' do
    expect { Klipp::Command.run *%w[--version] }.to raise_error SystemExit
    @output.string.should include Klipp::VERSION
  end

  it 'prints the help without any commands or options' do
    expect { Klipp::Command.run *%w[] }.to raise_error SystemExit
    @output.string.should include 'Options:'
    @output.string.should include '--help'
    @output.string.should include '--version'
  end

  it 'prints the help when asked for' do
    expect { Klipp::Command.run *["--help"] }.to raise_error SystemExit
    @output.string.should include 'Options:'
    @output.string.should include '--help'
    @output.string.should include '--version'
  end

  it 'exits the program when an unknown error is raised' do
    expect { Klipp::Command.run *["--help"] }.to raise_error SystemExit
  end

  it 'runs project commands' do
    expect { Klipp::Command.run *%w[project] }.to raise_error SystemExit
    @output.string.should include 'klipp project list'
  end

end