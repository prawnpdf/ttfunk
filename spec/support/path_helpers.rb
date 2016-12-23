module PathHelpers
  def test_font(name)
    base_path = File.expand_path(File.dirname(__FILE__) + "/../fonts")
    valid_filename = File.join(base_path, "#{name}.ttf")
    if File.file?(valid_filename)
      return valid_filename
    else
      raise ArgumentError, "#{valid_filename} not found"
    end
  end
end
