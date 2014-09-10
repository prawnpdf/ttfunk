module TTFunk
  class Table
    class Cmap

      module Format06
        attr_reader :language
        attr_reader :code_map

        def self.encode(charmap)
          next_id = 0
          glyph_map = { 0 => 0 }

          sorted_chars = charmap.keys.sort
          low_char, high_char = sorted_chars.first, sorted_chars.last
          entry_count = (1+high_char-low_char)
          glyph_indexes = Array.new(entry_count, 0)

          new_map = charmap.keys.sort.inject({}) do |map, code|
            glyph_map[charmap[code]] ||= next_id += 1
            map[code] = { :old => charmap[code], :new => glyph_map[charmap[code]] }
            glyph_indexes[code - low_char] = glyph_map[charmap[code]]
            map
          end

          subtable = [6, 10+entry_count*2, 0, low_char, entry_count, *glyph_indexes].pack('n*')

          { :charmap => new_map, :subtable => subtable, :max_glyph_id => next_id+1 }
        end

        def [](code)
          @code_map[code] || 0
        end

        def supported?
          true
        end

        private
          def parse_cmap!
            @language, firstcode, entrycount = read(8, 'x2nnn')
            @code_map = {}
            (firstcode...(firstcode+entrycount)).each do |code|
              @code_map[code] = read(2, 'n').first & 0xFFFF
            end
          end

      end

    end
  end
end
