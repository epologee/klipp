require 'spec_helper'

describe Klipp::Template do

  it 'initializes with a valid path and name' do
    path = File.join(__dir__, 'fixtures', 'templates')
    Klipp::Template.new(path, 'Example').should be_a Klipp::Template
  end

  it 'does not initialize with an invalid path/name' do
    expect {
      Klipp::Template.new('bull', 'shit').should_not be_a Klipp::Template
    }.to raise_error(EOFError)


  end

end