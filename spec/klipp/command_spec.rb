require 'spec_helper'
require 'klipp/version'

describe Klipp::Command do

  before do
    Klipp::Command.output = @output = StringIO.new
  end

  it 'prints the version number' do
    Klipp::Command.run *%w[--version]
    @output.string.should include Klipp::VERSION
  end

end