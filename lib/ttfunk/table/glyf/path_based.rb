module TTFunk
  class Table
    class Glyf
      class PathBased
        attr_reader :path, :horizontal_metrics
        attr_reader :x_min, :y_min, :x_max, :y_max
        attr_reader :left_side_bearing, :right_side_bearing

        def initialize(path, horizontal_metrics)
          @path = path
          @horizontal_metrics = horizontal_metrics

          x_coords = []
          y_coords = []

          path.commands.each do |command|
            type = command[:type]

            if type != :close
              x_coords << command[:x]
              y_coords << command[:y]
            end

            if %i[quad curve].include?(type)
              x_coords << command[:x1]
              y_coords << command[:y1]
            end

            if type == :curve
              x_coords << command[:x2]
              y_coords << command[:y2]
            end
          end

          @x_min = x_coords.min || 0
          @y_min = y_coords.min || 0
          @x_max = x_coords.max || horizontal_metrics.advance_width
          @y_max = y_coords.max || 0
          @left_side_bearing = horizontal_metrics.left_side_bearing
          @right_side_bearing =
            horizontal_metrics.advance_width -
            @left_side_bearing -
            (@x_max - @x_min)
        end
      end
    end
  end
end
