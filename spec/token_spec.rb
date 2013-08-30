require 'spec_helper'

describe Token do

  it 'has a token' do
    token = Token.new read_fixture('klipps/single-token.yml')
    token.token.should eq "PARTNER"
  end

end