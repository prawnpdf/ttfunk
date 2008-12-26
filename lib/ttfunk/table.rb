require 'ttfunk/reader'

module TTFunk
  class Table
    include Reader

    attr_reader :file
    attr_reader :offset
    attr_reader :length

    def initialize(file)
      @file = file

      info = file.directory_info(tag)

      if info
        @offset = info[:offset]
        @length = info[:length]

        parse_from(@offset) { parse! }
      end
    end

    def exists?
      !@offset.nil?
    end

    def tag
      self.class.name.split(/::/).last.downcase
    end
  end
end
