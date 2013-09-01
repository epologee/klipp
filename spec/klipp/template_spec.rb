require 'spec_helper'

describe Klipp::Template do

  it 'raises an error when initialized with an invalid path or name' do
    expect {
      Klipp::Template.new('bull', 'shit')
    }.to raise_error(RuntimeError)
  end

  context 'with a valid path and name' do
    before do
      @path = File.join(__dir__, '..', 'fixtures', 'templates')
    end

    it 'initializes' do
      Klipp::Template.new(@path, 'Example').should be_a Klipp::Template
    end

    it 'contains a list of tokens' do
      template = Klipp::Template.new(@path, 'Example')
      template.tokens.should have_at_least(1).item
    end

  end

end