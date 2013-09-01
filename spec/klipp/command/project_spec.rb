require 'spec_helper'

describe Klipp::Command::Project do

  before do
    Klipp::Command::Project.output = @output = StringIO.new
  end

  it 'lists projects by default' do
    project = Klipp::Command::Project.new []
    project.run
    @output.string.should include 'Example'
  end

end