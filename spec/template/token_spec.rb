require 'spec_helper'

describe Template::Token do

  before do
    @token = Template::Token.new
  end

  it 'has a default string type' do
    @token.type.should eq :string
  end

  it 'will not allow an unknown type' do
    expect { @token.type = :invalid_type }.to raise_error RuntimeError
  end

  context 'with type string' do

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

    it 'has a default validation hint' do
      @token.validation = /^[A-Z][A-Za-z0-9]{2,}$/
      @token.validation_hint.should include '(no custom validation_hint given)'
    end

    it 'accepts custom validation hints' do
      @token.validation_hint = 'Hint'
      @token.validation_hint.should eq 'Hint'
    end

    it 'invalidates booleans assigned' do
      expect { @token.value = true }.to raise_error RuntimeError
    end

  end

  context 'with type bool' do

    before do
      @token.type = :bool
    end

    it 'accepts boolean values' do
      @token.value = true
      @token.value.should eq true

      @token.value = false
      @token.value.should eq false
    end

    it 'invalidates strings assigned' do
      expect { @token.value = 'true' }.to raise_error RuntimeError
    end

  end

end