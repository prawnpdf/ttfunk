# frozen_string_literal: true

require_relative './reader'

module TTFunk
  class SubTable
    include Reader

    attr_reader :file, :table_offset, :length

    def initialize(file, offset, length = nil)
      @file = file
      @table_offset = offset
      @length = length
      parse_from(@table_offset) { parse! }
    end
  end
end
