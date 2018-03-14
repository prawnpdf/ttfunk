require_relative '../table'

module TTFunk
  class Table
    class Maxp < Table
      attr_reader :version
      attr_reader :num_glyphs
      attr_reader :max_points
      attr_reader :max_contours
      attr_reader :max_component_points
      attr_reader :max_component_contours
      attr_reader :max_zones
      attr_reader :max_twilight_points
      attr_reader :max_storage
      attr_reader :max_function_defs
      attr_reader :max_instruction_defs
      attr_reader :max_stack_elements
      attr_reader :max_size_of_instructions
      attr_reader :max_component_elements
      attr_reader :max_component_depth

      def self.encode(maxp, mapping)
        ''.tap do |table|
          num_glyphs = mapping.length
          table <<
            [maxp.version].pack('N') <<
            [
              num_glyphs, maxp.max_points, maxp.max_contours,
              maxp.max_component_points, maxp.max_component_contours,
              maxp.max_zones, maxp.max_twilight_points, maxp.max_storage,
              maxp.max_function_defs, maxp.max_instruction_defs,
              maxp.max_stack_elements, maxp.max_size_of_instructions,
              maxp.max_component_elements, maxp.max_component_depth
            ].pack('n*')
        end
      end

      private

      def parse!
        @version, @num_glyphs, @max_points, @max_contours,
          @max_component_points, @max_component_contours, @max_zones,
          @max_twilight_points, @max_storage, @max_function_defs,
          @max_instruction_defs, @max_stack_elements, @max_size_of_instructions,
          @max_component_elements, @max_component_depth = read(length, 'Nn*')
      end
    end
  end
end
