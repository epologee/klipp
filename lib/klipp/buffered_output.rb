module BufferedOutput

  @@output = nil

  def output=(output)
    @@output = output
  end

  def output
    @@output || $stdout
  end

end
