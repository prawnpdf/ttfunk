# frozen_string_literal: true

class TestFile
  attr_reader :io
  alias contents io

  def initialize(io)
    @io = io
  end

  # Fake font directory entry for the table with the provided tag.
  def directory_info(*)
    { offset: 0, length: io.length }
  end
end
