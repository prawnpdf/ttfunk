require 'ttfunk/table'

module TTFunk  
  class Table 
    class Hmtx < Table
      attr_reader :metrics
      attr_reader :left_side_bearings
      attr_reader :widths

      HorizontalMetric = Struct.new(:advance_width, :left_side_bearing)

      def for(glyph_id)
        @metrics[glyph_id] ||
          HorizontalMetric.new(@metrics.last.advance_width,
            @left_side_bearings[glyph_id - @metrics.length])
      end

      private

        def parse!
          @metrics = []

          file.horizontal_header.number_of_metrics.times do
            advance = read(2, "n").first
            lsb     = read_sshort(1).first
            @metrics.push HorizontalMetric.new(advance, lsb)
          end

          lsb_count = file.maximum_profile.num_glyphs - file.horizontal_header.number_of_metrics
          @left_side_bearings = read_sshort(lsb_count)

          @widths = @metrics.map { |metric| metric.advance_width }
          @widths += @left_side_bearings.length * @widths.last
        end
    end
  end
end
