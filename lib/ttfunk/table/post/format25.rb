require 'ttfunk/table/post/format10'
require 'stringio'

module TTFunk
  class Table
    class Post
      module Format25
        include Format10

        def glyph_for(code)
          POSTSCRIPT_GLYPHS[code + @offsets[code]] || ".notdef"
        end

        private

          def parse_format!
            number_of_glyphs = read(2, 'n').first
            @offsets = read(@number_of_glyphs, "c*")
          end
      end
    end
  end
end
