# frozen_string_literal: true

require_relative '../table'

module TTFunk
  class Table
    class Hhea < Table
      attr_reader :version
      attr_reader :ascent
      attr_reader :descent
      attr_reader :line_gap
      attr_reader :advance_width_max
      attr_reader :min_left_side_bearing
      attr_reader :min_right_side_bearing
      attr_reader :x_max_extent
      attr_reader :carot_slope_rise
      attr_reader :carot_slope_run
      attr_reader :caret_offset
      attr_reader :metric_data_format
      attr_reader :number_of_metrics

      def self.encode(hhea, hmtx)
        ''.b.tap do |table|
          table << [hhea.version].pack('N')
          table << [
            hhea.ascent, hhea.descent, hhea.line_gap, hhea.advance_width_max,
            hhea.min_left_side_bearing, hhea.min_right_side_bearing,
            hhea.x_max_extent, hhea.carot_slope_rise, hhea.carot_slope_run,
            hhea.caret_offset, 0, 0, 0, 0, hhea.metric_data_format,
            hmtx[:number_of_metrics]
          ].pack('n*')
        end
      end

      private

      def parse!
        @version = read(4, 'N').first
        @ascent, @descent, @line_gap = read_signed(3)
        @advance_width_max = read(2, 'n').first

        @min_left_side_bearing, @min_right_side_bearing, @x_max_extent,
          @carot_slope_rise, @carot_slope_run, @caret_offset,
          _reserved, _reserved, _reserved, _reserved,
          @metric_data_format = read_signed(11)

        @number_of_metrics = read(2, 'n').first
      end
    end
  end
end
