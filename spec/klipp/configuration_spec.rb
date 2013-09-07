require 'spec_helper'
require 'tmpdir'

describe Klipp::Configuration do

  it 'points to .klipp inside the user\'s home directory' do
    Klipp::Configuration.root_dir.should eq File.join(Dir.home, '.klipp')
  end

  context 'with auto create enabled' do

    before do
      Klipp::Configuration.auto_create_dirs = true
    end

    it 'auto creates the .klipp directory' do
      Dir.expects(:mkdir).once
      File.expects(:exists?).once.returns false
      Klipp::Configuration.root_dir
    end

  end

  context 'with root dir pointing to fixtures' do

    before do
      Klipp::Configuration.stubs(:root_dir).returns(File.join(File.dirname(__dir__), 'fixtures'))
    end

  end

end