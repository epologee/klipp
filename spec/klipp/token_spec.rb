require 'spec_helper'
require 'highline/import'

describe Klipp::Token do

  context 'with a single token yaml' do

    before do
      @token = Klipp::Token.new read_fixture('klipps/single-token.yml')
    end

    it 'has a title' do
      @token.title.should eq 'Partner name'
    end

    it 'has a subtitle' do
      @token.subtitle.should eq "e.g. 'FC Utrecht'"
    end

    it 'has a default value' do
      @token.default.should eq 'Qwerty'
    end

    it 'has a validate regex' do
      @token.validate.should eq /^[A-Z][A-Za-z0-9 ]{2,}$/
    end

    it 'has a response when not valid' do
      @token.not_valid_response.should eq 'Should be at least three characters long and start with a capital character'
    end

  end

  context 'with a valid token object' do

    before do
      @input = StringIO.new
      @output = StringIO.new
      @terminal = HighLine.new(@input, @output)
      @token = Klipp::Token.new read_fixture('klipps/single-token.yml')
    end

    it 'can ask a question' do
      simulate_input 'Something'

      @token.ask_for_input @terminal

      @output.string.should include 'Partner name'
      @output.string.should include "e.g. 'FC Utrecht'"
    end

    it 'records the answer' do
      name = 'Qwerty'
      simulate_input name

      @token.ask_for_input @terminal

      @token.value.should eq name
    end

    it 'uses highline validation' do
      simulate_input 'Qw'

      expect {
        @token.ask_for_input @terminal
      }.to raise_error(EOFError)

      @output.string.should include 'Should be at least three characters long and start with a capital character'
    end

    it 'prefills a default value' do
      simulate_input

      @token.ask_for_input @terminal

      @token.value.should eq 'Qwerty'
    end

    def simulate_input(value = '')
      @input << value << "\n"
      @input.rewind
    end

  end

end