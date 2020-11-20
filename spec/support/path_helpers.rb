# frozen_string_literal: true

module PathHelpers
  def test_font(name, ext = :ttf)
    base_path = File.expand_path("#{File.dirname(__FILE__)}/../fonts")
    valid_filename = File.join(base_path, "#{name}.#{ext}")
    if File.file?(valid_filename)
      valid_filename
    else
      raise ArgumentError, "#{valid_filename} not found"
    end
  end
end
