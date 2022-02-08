# frozen_string_literal: true

require_relative '../table'

module TTFunk
  class Table
    class Head < TTFunk::Table
      attr_reader :version
      attr_reader :font_revision
      attr_reader :checksum_adjustment
      attr_reader :magic_number
      attr_reader :flags
      attr_reader :units_per_em
      attr_reader :created
      attr_reader :modified
      attr_reader :x_min
      attr_reader :y_min
      attr_reader :x_max
      attr_reader :y_max
      attr_reader :mac_style
      attr_reader :lowest_rec_ppem
      attr_reader :font_direction_hint
      attr_reader :index_to_loc_format
      attr_reader :glyph_data_format

      class << self
        # Long date time (used in TTF headers) is defined here:
        # https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6.html
        # January 1, 1904 00:00:00 UTC basis used by Long date time
        LONG_DATE_TIME_BASIS = Time.new(1904, 1, 1, 0, 0, 0, 0).to_i
        private_constant :LONG_DATE_TIME_BASIS

        # mapping is new -> old glyph ids
        def encode(head, loca, mapping)
          EncodedString.new do |table|
            table <<
              [head.version, head.font_revision].pack('N2') <<
              Placeholder.new(:checksum, length: 4) <<
              [
                head.magic_number,
                head.flags, head.units_per_em,
                head.created, head.modified,
                *min_max_values_for(head, mapping),
                head.mac_style, head.lowest_rec_ppem, head.font_direction_hint,
                loca[:type] || 0, head.glyph_data_format
              ].pack('Nn2q>2n*')
          end
        end

        def from_long_date_time(ldt)
          Time.at(ldt + LONG_DATE_TIME_BASIS, in: 'UTC')
        end

        def to_long_date_time(time)
          time.to_i - LONG_DATE_TIME_BASIS
        end

        private

        def min_max_values_for(head, mapping)
          x_min = Min.new
          x_max = Max.new
          y_min = Min.new
          y_max = Max.new

          mapping.each do |_, old_glyph_id|
            glyph = head.file.find_glyph(old_glyph_id)
            next unless glyph

            x_min << glyph.x_min
            x_max << glyph.x_max
            y_min << glyph.y_min
            y_max << glyph.y_max
          end

          [
            x_min.value_or(0), y_min.value_or(0),
            x_max.value_or(0), y_max.value_or(0)
          ]
        end
      end

      private

      def parse!
        @version, @font_revision, @check_sum_adjustment, @magic_number,
          @flags, @units_per_em, @created, @modified = read(36, 'N4n2q>2')

        @x_min, @y_min, @x_max, @y_max = read_signed(4)

        @mac_style, @lowest_rec_ppem, @font_direction_hint,
          @index_to_loc_format, @glyph_data_format = read(10, 'n*')
      end
    end
  end
end
