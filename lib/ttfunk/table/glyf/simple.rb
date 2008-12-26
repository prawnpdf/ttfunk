require 'ttfunk/reader'

module TTFunk
  class Table
    class Glyf
      class Simple
        include Reader

        ON_CURVE   = 0x01
        X_SHORT    = 0x02
        Y_SHORT    = 0x04
        REPEAT     = 0x08
        X_SAME     = 0x10
        X_POSITIVE = 0x10
        Y_SAME     = 0x20
        Y_POSITIVE = 0x20

        attr_reader :number_of_contours
        attr_reader :x_min, :y_min, :x_max, :y_max
        attr_reader :end_points, :instructions, :flags
        attr_reader :xs, :ys

        def initialize(io, number_of_contours, x_min, y_min, x_max, y_max)
          @io = io
          @number_of_contours = number_of_contours
          @x_min, @y_min = x_min, y_min
          @x_max, @y_max = x_max, y_max

          @end_points = read(number_of_contours * 2, "n*")
          point_count = @end_points.last || 0

          instr_len = read(2, "n").first
          @instructions = io.read(instr_len)

          @flags = []
          while @flags.length < point_count
            flag = read(1, "C").first
            @flags << flag

            if flag & REPEAT != 0
              count = read(1, "C").first
              @flags.concat([flag] * count)
            end
          end

          @xs = []
          read_coords(@xs, point_count, X_SHORT, X_POSITIVE, X_SAME)

          @ys = []
          read_coords(@ys, point_count, Y_SHORT, Y_POSITIVE, Y_SAME)
        end

        private

          def read_coords(array, count, short_flag, positive_flag, same_flag)
            while array.length < count
              flag = @flags[array.length]

              if flag & short_flag != 0
                coord = read(1, "C").first
                coord = -coord if flag & positive_flag == 0
              elsif flag & same_flag != 0
                coord = 0
              else
                coord = read_signed(1).first
              end

              array << coord
            end
          end

          def io
            @io
          end
      end
    end
  end
end

