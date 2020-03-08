# frozen_string_literal: true

module TTFunk
  class Collection
    include Enumerable

    def self.open(path)
      if path.respond_to?(:read)
        result = yield new(path)
        path.rewind
        result
      else
        ::File.open(path, 'rb') do |io|
          yield new(io)
        end
      end
    end

    def initialize(io)
      tag = io.read(4)
      raise ArgumentError, 'not a TTC file' unless tag == 'ttcf'

      _major, _minor = io.read(4).unpack('n*')
      count = io.read(4).unpack1('N')
      @offsets = io.read(count * 4).unpack('N*')

      io.rewind
      @contents = io.read
      @cache = []
    end

    def count
      @offsets.length
    end

    def each
      count.times do |index|
        yield self[index]
      end
      self
    end

    def [](index)
      @cache[index] ||= TTFunk::File.new(@contents, @offsets[index])
    end
  end
end
