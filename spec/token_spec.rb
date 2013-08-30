require 'spec_helper'

describe Token do

  before do
    @token = Token.new read_fixture('klipps/single-token.yml')
  end

  it 'has a token' do
    @token.token.should eq 'PARTNER'
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