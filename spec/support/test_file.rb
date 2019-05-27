# frozen_string_literal: true

class TestFile
  attr_reader :io
  alias contents io

  def initialize(io)
    @io = io
  end

  def directory_info(*)
    { offset: 0, length: io.length }
  end
end
