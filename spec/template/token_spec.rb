require 'spec_helper'

describe Template::Token do

  before do
    @token = Template::Token.new
  end

  it 'has a hidden property' do
    @token.hidden = true
    @token.hidden.should eq true
  end

  it 'is not hidden by default' do
    @token.hidden.should eq false
  end

  it 'has a comment' do
    @token.comment = 'Comment'
    @token.comment.should eq 'Comment'
  end

  it 'has a validation' do
    @token.validation = /^[A-Z][A-Za-z0-9]{2,}$/
    @token.validation.should eq /^[A-Z][A-Za-z0-9]{2,}$/
  end

  it 'has a validation_hint' do
    @token.validation_hint = 'Hint'
    @token.validation_hint.should eq 'Hint'
  end


end