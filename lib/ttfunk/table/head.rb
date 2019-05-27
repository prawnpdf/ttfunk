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

      def self.encode(head, loca)
        EncodedString.new do |table|
          table <<
            [head.version, head.font_revision].pack('N2') <<
            Placeholder.new(:checksum, length: 4) <<
            [
              head.magic_number,
              head.flags, head.units_per_em,
              head.created, head.modified,
              head.x_min, head.y_min, head.x_max, head.y_max,
              head.mac_style, head.lowest_rec_ppem, head.font_direction_hint,
              loca[:type], head.glyph_data_format
            ].pack('Nn2q2n*')
        end
      end

      private

      def parse!
        @version, @font_revision, @check_sum_adjustment, @magic_number,
          @flags, @units_per_em, @created, @modified = read(36, 'N4n2q2')

        @x_min, @y_min, @x_max, @y_max = read_signed(4)

        @mac_style, @lowest_rec_ppem, @font_direction_hint,
          @index_to_loc_format, @glyph_data_format = read(10, 'n*')
      end
    end
  end
end
