require_relative './reader'

module TTFunk
  class SubTable
    include Reader

    attr_reader :file, :table_offset

    # set by parse! in derived classes
    attr_reader :length

    def initialize(file, offset, length = nil)
      @file = file
      @table_offset = offset
      # if length is nil, it should be set to an actual value in derived classes
      @length = length
      parse_from(@table_offset) { parse! }
    end
  end
end
