# frozen_string_literal: true

require_relative '../../reader'

module TTFunk
  class Table
    class Glyf
      # Composite TrueType glyph.
      class Compound
        include Reader

        # Flags bit 0: arg1 and arg2 are words.
        ARG_1_AND_2_ARE_WORDS = 0x0001

        # Flags bit 1: arg1 and arg2 are x and y offsets; otherwise they are
        # point numbers for point matching.
        ARGS_ARE_XY_VALUES = 0x0002

        # Flags bit 3: there is a simple scale for the component.
        WE_HAVE_A_SCALE = 0x0008

        # Flags bit 5: at least one more glyph after this one.
        MORE_COMPONENTS = 0x0020

        # Flags bit 6: the x direction will use a different scale from the
        # y direction.
        WE_HAVE_AN_X_AND_Y_SCALE = 0x0040

        # Flags bit 7: there is a 2 by 2 transformation that will be used to
        # scale the component.
        WE_HAVE_A_TWO_BY_TWO = 0x0080

        # Flags bit 8: following the last component are instructions for the
        # composite character.
        WE_HAVE_INSTRUCTIONS = 0x0100

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

        # IDs of compound glyphs.
        attr_reader :glyph_ids

        # Component glyph.
        #
        # @!attribute [rw] flags
        #   Component flag.
        #   @return [Integer]
        # @!attribute [rw] glyph_index
        #   Glyph index of component.
        #   @return [Integer]
        # @!attribute [rw] arg1
        #   x-offset for component or point number.
        #   @return [Integer]
        # @!attribute [rw] arg2
        #   y-offset for component or point number.
        #   @return [Integer]
        # @!attribute [rw] transform
        #   Component transformation, as F2Dot14 values: `nil` (identity),
        #   `[scale]`, `[x_scale, y_scale]`, or
        #   `[x_scale, scale01, scale10, y_scale]`.
        #   @return [nil, Array<Float>]
        Component = Struct.new(:flags, :glyph_index, :arg1, :arg2, :transform)

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

          # Because TTFunk only cares about glyphs insofar as they (1) provide
          # a bounding box for each glyph, and (2) can be rewritten into a
          # font subset, we don't really care about the rest of the glyph data
          # except as a whole. Thus, we don't actually decompose the glyph
          # into it's parts--all we really care about are the locations within
          # the raw string where the component glyph ids are stored, so that
          # when we rewrite this glyph into a subset we can rewrite the
          # component glyph-ids so they are correct for the subset.

          @glyph_ids = []
          @glyph_id_offsets = []
          offset = 10 # 2 bytes for each of num-contours, min x/y, max x/y

          loop do
            flags, glyph_id = @raw[offset, 4].unpack('n*')
            @glyph_ids << glyph_id
            @glyph_id_offsets << (offset + 2)

            break if flags.nobits?(MORE_COMPONENTS)

            offset += 4

            offset +=
              if flags.nobits?(ARG_1_AND_2_ARE_WORDS)
                2
              else
                4
              end

            if flags.allbits?(WE_HAVE_A_TWO_BY_TWO)
              offset += 8
            elsif flags.allbits?(WE_HAVE_AN_X_AND_Y_SCALE)
              offset += 4
            elsif flags.allbits?(WE_HAVE_A_SCALE)
              offset += 2
            end
          end
        end

        # Is this a composite glyph?
        # @return [true]
        def compound?
          true
        end

        # Recode glyph.
        #
        # @param mapping [Hash{Integer => Integer}] a hash mapping old glyph IDs
        #   to new glyph IDs.
        # @return [String]
        def recode(mapping)
          result = raw.dup
          new_ids = glyph_ids.map { |id| mapping[id] }

          new_ids.zip(@glyph_id_offsets).each do |new_id, offset|
            result[offset, 2] = [new_id].pack('n')
          end

          result
        end

        # Fully parsed component records of this composite glyph.
        #
        # @return [Array<Component>]
        def components
          @components ||=
            begin
              io = StringIO.new(raw)
              io.pos = 10
              components = []

              loop do
                component = parse_component(io)
                components << component
                break if component.flags.nobits?(MORE_COMPONENTS)
              end

              components
            end
        end

        private

        def parse_component(io)
          flags, glyph_index = io.read(4).unpack('n*')
          arg1, arg2 = read_args(io, flags)
          Component.new(flags, glyph_index, arg1, arg2, read_transform(io, flags))
        end

        def read_args(io, flags)
          size = flags.allbits?(ARG_1_AND_2_ARE_WORDS) ? 2 : 1
          args = Array.new(2) { io.read(size).unpack1(size == 2 ? 'n' : 'C') }
          return args if flags.nobits?(ARGS_ARE_XY_VALUES)

          args.map { |arg| BinUtils.twos_comp_to_int(arg, bit_width: size * 8) }
        end

        def read_transform(io, flags)
          if flags.allbits?(WE_HAVE_A_TWO_BY_TWO)
            Array.new(4) { read_f2dot14(io) }
          elsif flags.allbits?(WE_HAVE_AN_X_AND_Y_SCALE)
            Array.new(2) { read_f2dot14(io) }
          elsif flags.allbits?(WE_HAVE_A_SCALE)
            [read_f2dot14(io)]
          end
        end

        def read_f2dot14(io)
          BinUtils.twos_comp_to_int(io.read(2).unpack1('n'), bit_width: 16) / 16_384.0
        end
      end
    end
  end
end
