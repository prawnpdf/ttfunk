require 'ttfunk/table'

module TTFunk  
  class Table
    class Post < Table
      attr_reader :format
      attr_reader :italic_angle
      attr_reader :underline_position
      attr_reader :underline_thickness
      attr_reader :fixed_pitch
      attr_reader :min_mem_type42
      attr_reader :max_mem_type42
      attr_reader :min_mem_type1
      attr_reader :max_mem_type1

      attr_reader :subtable

      def fixed_pitch?
        @fixed_pitch != 0
      end

      def glyph_for(code)
        ".notdef"
      end

      private

        def parse!
          @format, @italic_angle, @underline_position, @underline_thickness,
            @fixed_pitch, @min_mem_type42, @max_mem_type42, 
            @min_mem_type1, @max_mem_type1 = read(32, "N2n2N*")

          end_of_table = offset + length

          @subtable = case @format
            when 0x00010000 then extend(Post::Format10)
            when 0x00020000 then extend(Post::Format20)
            when 0x00025000 then extend(Post::Format25)
            when 0x00030000 then extend(Post::Format30)
            when 0x00040000 then extend(Post::Format40)
            end

          parse_table!
        end

        def parse_table!
          warn "postscript table format 0x%08X is not supported" % @format
        end
    end
    
  end
end

require 'ttfunk/table/post/format10'
require 'ttfunk/table/post/format20'
require 'ttfunk/table/post/format25'
require 'ttfunk/table/post/format30'
require 'ttfunk/table/post/format40'
