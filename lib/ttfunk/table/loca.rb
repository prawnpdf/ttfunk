require 'ttfunk/table'

module TTFunk
  class Table
    class Loca < Table
      attr_reader :offsets

      def index_of(glyph_id)
        @offsets[glyph_id]
      end

      def size_of(glyph_id)
        @offsets[glyph_id+1] - @offsets[glyph_id]
      end

      private

        def parse!
          type = file.header.index_to_loc_format == 0 ? "n" : "N"
          @offsets = read(length, "#{type}*")

          if file.header.index_to_loc_format == 0
            @offsets.map! { |v| v * 2 }
          end
        end
    end
  end
end
