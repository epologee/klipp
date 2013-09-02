require 'spec_helper'

describe Klipp::Command::Project do

  before do
    @output = Klipp::Command.output = Klipp::Command::Project.output = StringIO.new
    Klipp::Configuration.root_dir = File.join(__dir__, '..', '..', 'fixtures')
  end

  it 'show help by default' do
    project = Klipp::Command::Project.new []
    expect { project.run }.to raise_error Klipp::Command::Help
  end

  it 'lists templates' do
    project = Klipp::Command::Project.new %w[list]
    project.run
    @output.string.should include 'Example'
  end

  it 'shows help when not attempting to prepare without a template' do
    project = Klipp::Command::Project.new %w[prepare]
    expect { project.run }.to raise_error Klipp::Command::Help
  end

  it 'raises an error when attempting to prepare a non-existing template' do
    project = Klipp::Command::Project.new %w[prepare NonExistingTemplate]
    expect { project.run }.to raise_error RuntimeError
  end

  it 'raises an error when attempting to overwrite an existing klippfile' do
    path = Tempfile.new('foo').path
    File.open(path, 'w') { |f| f.write('This seat is taken') }
    Klipp::Command::Project.file_output = path
    project = Klipp::Command::Project.new %w[prepare Example]
    expect { project.run }.to raise_error RuntimeError
    Klipp::Command::Project.file_output = nil
  end

  # Note from EP to EP: You're testing the wrong class here, no?!
  it 'prepares a template by creating a .klippfile' do
    path = File.join(Dir.mktmpdir, 'Temp.klippfile')
    File.exists?(path).should be false
    Klipp::Command::Project.file_output = path
    project = Klipp::Command::Project.new %w[prepare Example]
    project.run
    File.read(path).should include 'PARTNER:'
    File.read(path).should include 'CLASS_PREFIX:'
    Klipp::Command::Project.file_output = nil
  end

end