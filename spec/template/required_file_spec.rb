require 'spec_helper'

describe Template::RequiredFile do

  it 'initializes with a file name' do
    file = Template::RequiredFile.new 'file.txt'
    file.should_not be_nil
  end

  it 'requires a file name' do
    expect { file = Template::RequiredFile.new }.to raise_error ArgumentError
  end

  it 'requires the file name to not be empty' do
    expect { file = Template::RequiredFile.new '' }.to raise_error RuntimeError
  end

  it 'requires the file name to be sanitized' do
    expect { Template::RequiredFile.new '.what&up'}.to raise_error RuntimeError
    expect { Template::RequiredFile.new 'not/a/file'}.to raise_error RuntimeError
  end

  context 'with file.txt' do

    before do
      @file = Template::RequiredFile.new 'file.txt'
    end

    it 'has a name' do
      @file.name.should eq 'file.txt'
    end

    it 'has a comment' do
      @file.comment = 'Comment'
      @file.comment.should eq 'Comment'
    end

    it 'takes a directory' do
      @file.directory = 'images'
      @file.directory.should eq 'images'
    end

    it 'has a default directory' do
      @file.directory.should eq '.'
    end
  end

end