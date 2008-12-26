module TTFunk
  class Table
    class Cmap

      module Format04
        attr_reader :language
        attr_reader :code_map

        def [](code)
          @code_map[code] || 0
        end

        def supported?
          true
        end

        private

          def parse_cmap!
            length, @language, segcount_x2 = read(6, "nnn")
            segcount = segcount_x2 / 2

            io.read(6) # skip searching hints

            end_code = read(segcount_x2, "n*")
            io.read(2) # skip reserved value
            start_code = read(segcount_x2, "n*")
            id_delta = read_signed(segcount)
            id_range_offset = read(segcount_x2, "n*")

            glyph_ids = read(length - io.pos + @offset, "n*")

            @code_map = {}

            end_code.each_with_index do |tail, i|
              start_code[i].upto(tail) do |code|
                if id_range_offset[i].zero?
                  glyph_id = code + id_delta[i]
                else
                  index = id_range_offset[i] / 2 + (code - start_code[i]) - (segcount - i)
                  glyph_id = glyph_ids[index] || 0 # because some TTF fonts are broken
                  glyph_id += id_delta[i] if glyph_id != 0
                end

                @code_map[code] = glyph_id & 0xFFFF
              end
            end
          end
      end

    end
  end
end
