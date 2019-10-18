# frozen_string_literal: true

require_relative '../table'

module TTFunk
  class Table
    class Maxp < Table
      DEFAULT_MAX_COMPONENT_DEPTH = 1
      MAX_V1_TABLE_LENGTH = 34

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
        ''.b.tap do |table|
          num_glyphs = mapping.length
          table << [maxp.version, num_glyphs].pack('Nn')

          if maxp.version == 0x10000
            table << [
              maxp.max_points, maxp.max_contours, maxp.max_component_points,
              maxp.max_component_contours, maxp.max_zones,
              maxp.max_twilight_points, maxp.max_storage,
              maxp.max_function_defs, maxp.max_instruction_defs,
              maxp.max_stack_elements, maxp.max_size_of_instructions,
              maxp.max_component_elements, maxp.max_component_depth
            ].pack('n*')
          end
        end
      end

      private

      def parse!
        @version, @num_glyphs = read(6, 'Nn')

        if @version == 0x10000
          @max_points, @max_contours, @max_component_points,
            @max_component_contours, @max_zones, @max_twilight_points,
            @max_storage, @max_function_defs, @max_instruction_defs,
            @max_stack_elements, @max_size_of_instructions,
            @max_component_elements = read(26, 'Nn*')

          # a number of fonts omit these last two bytes for some reason,
          # so we have to supply a default here to prevent nils
          @max_component_depth = if length == MAX_V1_TABLE_LENGTH
                                   read(2, 'n').first
                                 else
                                   DEFAULT_MAX_COMPONENT_DEPTH
                                 end
        end
      end
    end
  end
end
