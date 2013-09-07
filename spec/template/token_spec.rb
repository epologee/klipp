require 'spec_helper'

describe Template::Token do

  before do
    @token = Template::Token.new('TOKEN_NAME')
  end

  it 'has a hidden property' do
    @token.hidden = true
    @token.hidden.should eq true
  end

  it 'is not hidden by default' do
    @token.hidden.should eq false
  end

end