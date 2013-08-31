require 'spec_helper'
require 'klipp/version'

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
    Klipp::Command.run *%w[--version]
    @output.string.should include Klipp::VERSION
  end

  it 'prints the help without any commands or options' do
    Klipp::Command.run *%w[]
    @output.string.should include 'Options:'
    @output.string.should include '--help'
    @output.string.should include '--version'
  end

  it 'prints the help when asked for' do
    Klipp::Command.run *["--help"]
    @output.string.should include 'Options:'
    @output.string.should include '--help'
    @output.string.should include '--version'
  end

  it 'exits the program when an unknown error is raised' do
    Klipp::Command.expects(:parse).returns StandardError.new
    expect { Klipp::Command.run *["--help"] }.to raise_error SystemExit
  end

end
