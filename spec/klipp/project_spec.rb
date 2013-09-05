require 'spec_helper'
require 'tmpdir'

describe Klipp::Project do

  context 'with a template' do

    before do
      fixtures_dir = File.join(File.dirname(__dir__), 'fixtures')
      Klipp::Configuration.stubs(:root_dir).returns fixtures_dir
      @template = Klipp::Template.new(Klipp::Configuration.templates_dir, 'Example')
      @template.load_klippfile File.join(fixtures_dir, 'klipps', 'Example.klippfile')
      @project = Klipp::Project.new(@template)
      Dir.stubs(:pwd).returns(Dir.mktmpdir)
    end

    it 'copies files while replacing paths, including hidden files' do
      @project.create
      File.exists?(File.join Dir.pwd, 'Example', '.hiddenfile').should be true
      File.exists?(File.join Dir.pwd, 'Example', 'ProjectX').should be true
      File.exists?(File.join Dir.pwd, 'Example', 'PJXPrefixedFile.txt').should be true
      File.exists?(File.join Dir.pwd, 'Example', 'ProjectX', 'BinaryFile.png').should be true
      File.exists?(File.join Dir.pwd, 'Example', 'ProjectX', 'PJXPrefixedFileInDirectory.txt').should be true
    end

    it 'replaces file contens while transferring' do
      @project.create
      File.read(File.join Dir.pwd, 'Example', 'PJXPrefixedFile.txt').should include 'Regular content stays untouched'
      File.read(File.join Dir.pwd, 'Example', 'PJXPrefixedFile.txt').should include 'Tokens are replaced: ProjectX'
      File.read(File.join Dir.pwd, 'Example', 'PJXPrefixedFile.txt').should include 'Even if it\'s in the middle of something else BlablablaProjectXBlabla'
    end

    it 'copies binary files without replacing contents' do
      @project.create
      template_png = File.join(Klipp::Configuration.templates_dir, 'Example', 'XXPROJECT_IDXX', 'BinaryFile.png')
      transferred_png = File.join(Dir.pwd, 'Example', 'ProjectX', 'BinaryFile.png')
      FileUtils.compare_file(template_png, transferred_png).should be true
    end

    it 'halts transfer if the directory already exists' do
      FileUtils.mkdir_p File.join(Dir.pwd, 'Example')
      expect { @project.create }.to raise_error RuntimeError
    end

  end

end
