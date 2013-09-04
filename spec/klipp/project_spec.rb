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

    it 'copies files while replacing paths' do
      @project.create
      File.exists?(File.join Dir.pwd, 'ProjectX').should be true
      File.exists?(File.join Dir.pwd, 'ProjectX/BinaryFile.png').should be true
      File.exists?(File.join Dir.pwd, 'ProjectX/PJXPrefixedFileInDirectory.txt').should be true
      File.exists?(File.join Dir.pwd, 'ProjectX/PJXPrefixedFile.txt').should be true
    end

  end

end
