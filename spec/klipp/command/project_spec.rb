require 'spec_helper'

describe Klipp::Command::Project do

  before do
    @output = Klipp::Command.output = Klipp::Command::Project.output = StringIO.new
    Klipp::Configuration.root_dir = File.join(__dir__, '..', '..', 'fixtures')
  end

  xit 'show help by default' do
    project = Klipp::Command::Project.new []
    expect { project.run }.to raise_error Klipp::Command::Help
    @output.string.should include '--help'
  end

  it 'lists templates' do
    project = Klipp::Command::Project.new %w[list]
    project.run
    @output.string.should include 'Example'
  end

end