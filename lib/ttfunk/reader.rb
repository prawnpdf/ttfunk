module TTFunk
  module Reader
    private

      def io
        @file.contents
      end

      def read(bytes, format)
        io.read(bytes).unpack(format)
      end

      def read_signed(count)
        read(count*2, "n*").map { |i| to_signed(i) }
      end

      def to_signed(n)
        (n>=0x8000) ? -((n ^ 0xFFFF) + 1) : n
      end

      def parse_from(position)
        saved, io.pos = io.pos, position
        result = yield
        io.pos = saved
        return result
      end
  end
end
