require 'ttfunk/table'

module TTFunk
  class Table
    class Glyf < Table
      def at(glyph_offset)
        return @cache[glyph_offset] if @cache.key?(glyph_offset)

        parse_from(offset + glyph_offset) do
          number_of_contours, x_min, y_min, x_max, y_max = read_signed(5)

          @cache[glyph_offset] = if number_of_contours == -1
              Compound.new(io, x_min, y_min, x_max, y_max)
            else
              Simple.new(io, number_of_contours, x_min, y_min, x_max, y_max)
            end
        end
      end

      private

        def parse!
          # because the glyf table is rather complex to parse, we defer
          # the parse until we need a specific glyf, and then cache it.
          @cache = {}
        end
    end
  end
end

require 'ttfunk/table/glyf/compound'
require 'ttfunk/table/glyf/simple'
