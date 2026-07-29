# frozen_string_literal: true

require_relative '../../reader'

module TTFunk
  class Table
    class Glyf
      # Simple TrueType glyph
      class Simple
        # Flags bit 0: point is on the curve.
        ON_CURVE_POINT = 0x01

        # Flags bit 1: x coordinate is 1 byte long.
        X_SHORT_VECTOR = 0x02

        # Flags bit 2: y coordinate is 1 byte long.
        Y_SHORT_VECTOR = 0x04

        # Flags bit 3: the flag byte is followed by a repeat count.
        REPEAT_FLAG = 0x08

        # Flags bit 4: short x is positive, or long x is omitted and the
        # coordinate is the same as the previous point's.
        X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR = 0x10

        # Flags bit 5: short y is positive, or long y is omitted and the
        # coordinate is the same as the previous point's.
        Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR = 0x20

        # Point of a decoded glyph outline contour.
        #
        # @!attribute [rw] x
        #   X coordinate, in font units.
        #   @return [Integer, Float]
        # @!attribute [rw] y
        #   Y coordinate, in font units.
        #   @return [Integer, Float]
        # @!attribute [rw] on_curve
        #   Whether the point is on the curve; `false` for quadratic Bezier
        #   control points.
        #   @return [Boolean]
        Point = Struct.new(:x, :y, :on_curve)

        # Glyph ID.
        # @return [Integer]
        attr_reader :id

        # Binary serialization of this glyph.
        # @return [String]
        attr_reader :raw

        # Number of contours in this glyph.
        # @return [Integer]
        attr_reader :number_of_contours

        # Minimum x for coordinate.
        # @return [Integer]
        attr_reader :x_min

        # Minimum y for coordinate.
        # @return [Integer]
        attr_reader :y_min

        # Maximum x for coordinate.
        # @return [Integer]
        attr_reader :x_max

        # Maximum y for coordinate.
        # @return [Integer]
        attr_reader :y_max

        # Point indices for the last point of each contour.
        # @return [Array<Integer>]
        attr_reader :end_points_of_contours

        # Total number of bytes for instructions.
        # @return [Integer]
        attr_reader :instruction_length

        # Instruction byte code.
        # @return [Array<Integer>]
        attr_reader :instructions

        # @param id [Integer] glyph ID.
        # @param raw [String]
        def initialize(id, raw)
          @id = id
          @raw = raw
          io = StringIO.new(raw)

          @number_of_contours, @x_min, @y_min, @x_max, @y_max =
            io.read(10).unpack('n*').map { |i|
              BinUtils.twos_comp_to_int(i, bit_width: 16)
            }

          @end_points_of_contours = io.read(number_of_contours * 2).unpack('n*')
          @instruction_length = io.read(2).unpack1('n')
          @instructions = io.read(instruction_length).unpack('C*')
        end

        # Is this glyph compound?
        # @return [false]
        def compound?
          false
        end

        # Recode glyph.
        #
        # @param _mapping Unused, here for API compatibility.
        # @return [String]
        def recode(_mapping)
          raw
        end

        # End point index of last contour.
        # @return [Integer]
        def end_point_of_last_contour
          end_points_of_contours.last + 1
        end

        # Decoded outline contours of this glyph.
        #
        # @return [Array<Array<Point>>] one array of points per contour, in
        #   drawing order.
        def contours
          @contours ||= split_contours(decode_points)
        end

        private

        def point_count
          end_points_of_contours.empty? ? 0 : end_points_of_contours.last + 1
        end

        def decode_points
          io = StringIO.new(raw)
          io.pos = 10 + (number_of_contours * 2) + 2 + instruction_length
          flags = read_flags(io, point_count)
          x_coordinates = read_coordinates(io, flags, X_SHORT_VECTOR, X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR)
          y_coordinates = read_coordinates(io, flags, Y_SHORT_VECTOR, Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR)

          flags.each_index.map { |i|
            Point.new(x_coordinates[i], y_coordinates[i], flags[i].anybits?(ON_CURVE_POINT))
          }
        end

        def read_flags(io, count)
          flags = []

          while flags.length < count
            flag = io.readbyte
            flags << flag
            io.readbyte.times { flags << flag } if flag.anybits?(REPEAT_FLAG)
          end

          flags.first(count)
        end

        # Coordinates are stored as deltas from the previous point, with a
        # per-point size (0, 1, or 2 bytes) chosen by the flag bits.
        def read_coordinates(io, flags, short_bit, same_bit)
          coordinate = 0

          flags.map { |flag|
            coordinate +=
              if flag.anybits?(short_bit)
                flag.anybits?(same_bit) ? io.readbyte : -io.readbyte
              elsif flag.nobits?(same_bit)
                BinUtils.twos_comp_to_int(io.read(2).unpack1('n'), bit_width: 16)
              else
                0
              end

            coordinate
          }
        end

        def split_contours(points)
          start = 0

          end_points_of_contours.map { |last|
            contour = points[start..last]
            start = last + 1
            contour
          }
        end
      end
    end
  end
end
