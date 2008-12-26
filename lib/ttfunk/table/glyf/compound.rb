require 'ttfunk/reader'

module TTFunk
  class Table
    class Glyf
      class Compound
        include Reader

        ARG_1_AND_2_ARE_WORDS    = 0x0001
        WE_HAVE_A_SCALE          = 0x0008
        MORE_COMPONENTS          = 0x0020
        WE_HAVE_AN_X_AND_Y_SCALE = 0x0040
        WE_HAVE_A_TWO_BY_TWO     = 0x0080
        WE_HAVE_INSTRUCTIONS     = 0x0100

        attr_reader :x_min, :y_min, :x_max, :y_max
        attr_reader :components
        attr_reader :instructions

        Component = Struct.new(:flags, :glyph_index, :arg1, :arg2, :transform)

        def initialize(io, x_min, y_min, x_max, y_max)
          @io = io
          @x_min, @y_min, @x_max, @y_max = x_min, y_min, x_max, y_max

          @components = []
          instr_requests = 0

          loop do
            flags, glyph_index = read(4, "n*")
            if flags & ARG_1_AND_2_ARE_WORDS != 0
              arg1, arg2 = read(4, "n*")
            else
              arg1, arg2 = read(2, "C*")
            end

            if flags & WE_HAVE_A_TWO_BY_TWO != 0
              transform = read(8, "n*")
            elsif flags & WE_HAVE_AN_X_AND_Y_SCALE != 0
              transform = read(4, "n*")
            elsif flags & WE_HAVE_A_SCALE != 0
              transform = read(2, "n")
            else
              transform = []
            end

            instr_requests += 1 if flags & WE_HAVE_INSTRUCTIONS != 0

            @components << Component.new(flags, glyph_index, arg1, arg2, transform)
            break unless flags & MORE_COMPONENTS != 0
          end

          # The docs are a bit vague on how instructions are to be parsed from
          # a compound glyph. This seems to work for the glyphs I've tried, but...
          @instructions = ""
          while instr_requests > 0
            length = read(2, "n").first
            @instructions << io.read(length)
            instr_requests -= 1
          end
        end

        private

          def io
            @io
          end
      end
    end
  end
end

