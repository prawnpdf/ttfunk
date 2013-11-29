require 'ttfunk/encoding/mac_roman'
require 'ttfunk/encoding/windows_1252'

module TTFunk
  class Table
    class Cmap

      module Format06
        attr_reader :language
        attr_reader :code_map
        attr_reader :first_code, :entry_count

        # Expects a hash mapping character codes to glyph ids (where the
        # glyph ids are from the original font). Returns a hash including
        # a new map (:charmap) that maps the characters in charmap to a
        # another hash containing both the old (:old) and new (:new) glyph
        # ids. The returned hash also includes a :subtable key, which contains
        # the encoded subtable for the given charmap.
        def self.encode(charmap)
          next_id = 0
          glyph_indexes = Array.new(charmap.length, 0)
          glyph_map = { 0 => 0 }

          new_map = charmap.keys.sort.inject({}) do |map, code|
            glyph_map[charmap[code]] ||= next_id += 1
            map[code] = { :old => charmap[code], :new => glyph_map[charmap[code]] }
            glyph_indexes[code] = glyph_map[charmap[code]]
            map
          end

          # format, length, language, firstCode, entryCount, indices
          subtable = [6, 262, 0, charmap.first.key, charmap.length, *glyph_indexes].pack("nnnnn*")

          { :charmap => new_map, :subtable => subtable, :max_glyph_id => next_id+1 }
        end

        def [](code)
          @code_map[code - @first_code] || 0
        end

        def supported?
          true
        end

        private

          def parse_cmap!
            length, @language, @first_code, @entry_count = read(8, "nnnn")
            # 2 bytes per UInt16
            @code_map = read(@entry_count * 2, "n*")
          end
      end

    end
  end
end
