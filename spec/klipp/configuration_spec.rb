require 'spec_helper'
require 'tmpdir'

describe Klipp::Configuration do

  it 'points to .klipp inside the user\'s home directory' do
    Klipp::Configuration.root_dir.should eq File.join(Dir.home, '.klipp')
  end

  context 'with root pointing to fixtures' do

    before do
      Klipp::Configuration.root_dir = File.join(__dir__, '..', 'fixtures')
    end

    it 'initializes' do
      Klipp::Configuration.new.should be_a Klipp::Configuration
    end

  end

  context 'with root pointing to a non existing directory' do

    before do
      @root_dir = Klipp::Configuration.root_dir = File.join(Dir.mktmpdir, 'phantom-root')
    end

    it 'raises an error when initializing' do
      expect { Klipp::Configuration.new }.to raise_error RuntimeError
    end

    context 'with auto create directories enabled' do

      before do
        Klipp::Configuration.auto_create_dirs = true
      end

      it 'creates the root directory when initializing' do
        Klipp::Configuration.new
        Klipp::Configuration.root_dir.should eq @root_dir
        File.directory?(Klipp::Configuration.root_dir).should eq true
      end

      after do
        Klipp::Configuration.auto_create_dirs = false
      end

    end

  end

  after do
    Klipp::Configuration.root_dir = nil
  end

end