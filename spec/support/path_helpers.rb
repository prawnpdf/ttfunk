# frozen_string_literal: true

module PathHelpers
  # Get a test font file.
  #
  # @param name [String] name of the font file
  # @param ext [Symbol, String] font file extension
  # @return [String] full path to the test font file
  # @raise [ArgumentError] if the requested font file can't be found
  def test_font(name, ext = :ttf)
    base_path = File.expand_path('../fonts', __dir__)
    valid_filename = File.join(base_path, "#{name}.#{ext}")
    if File.file?(valid_filename)
      valid_filename
    else
      raise ArgumentError, "#{valid_filename} not found"
    end
  end
end
