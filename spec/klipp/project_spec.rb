require 'spec_helper'

describe Klipp::Project do

  xit 'initializes with a valid path and name' do
    path = File.join(__dir__, '..', 'fixtures', 'templates')
    Klipp::Template.new(path, 'Example').should be_a Klipp::Template
  end

end