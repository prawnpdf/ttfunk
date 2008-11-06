class Array
  alias_method :original_index, :index
  
  def index(*a)
    if block_given?
      (0...size).find { |e| yield(self[e]) }
    else
      original_index(*a)
    end
  end
end

class TTFunk
  class File
    def initialize(file)
      @file = file
       open_file { |fh| @directory = Table::Directory.new(fh) }
    end
    
    def open_file
      ::File.open(@file,"rb") do |fh|
        yield(fh)
      end
    end
    
    def self.has_tables(*tables)
      tables.each { |t| has_table(t) }
    end
    
    def self.has_table(t)
      t = t.to_s
      
      define_method t do
        var = "@#{t}"
        if ivar = instance_variable_get(var) 
          return ivar  
        else
          klass = Table.const_get(t.capitalize)
          open_file do |fh| 
            instance_variable_set(var, 
              klass.new(fh, self, directory_info(t)))
          end
        end
      end
    end
    
    def directory_info(table)
      directory.tables[table]
    end
    
    attr_reader :directory
    has_tables :head, :hhea, :name, :maxp, :hmtx, :cmap
  end
  
  class Table 
    
    class Cmap < Table
      def initialize(fh, font, info)
        @file = fh
        @file.pos = info[:offset]
        
        @version, @num_tables = @file.read(4).unpack("n2")
        
        process_subtables(info[:offset])
      end
      
      def process_subtables(table_start)
        @sub_tables = {}
        @formats = {}
        @num_tables.times do
          platform_id, encoding_id, offset = @file.read(8).unpack("n2N")
          @sub_tables[[platform_id, encoding_id]] = offset
        end
        
        @sub_tables.each do |ident, offset|
          @file.pos = table_start + offset
          format = @file.read(2).unpack("n").first 
          case format
          when 0
            @file.read(4) # skip length, language for now
            glyph_ids = @file.read(256).unpack("C256")
            @formats[0] = glyph_ids
          when 4
            length, language = @file.read(4).unpack("n2")
            segcount_x2, search_range, entry_selector, range_shift = 
              @file.read(8).unpack("n4")
            end_count = @file.read(segcount_x2).unpack("n#{segcount_x2 / 2}")
            
            @file.read(2) # skip reserved value
            
            start_count = @file.read(segcount_x2).unpack("n#{segcount_x2 / 2}")
            id_delta = @file.read(segcount_x2).unpack("n#{segcount_x2 / 2}").
                         map { |e| to_signed(e) }
            id_range_offset = @file.read(segcount_x2).unpack("n#{segcount_x2 / 2}")

            remaining_shorts = (@file.pos - table_start) / 2
            glyph_ids = @file.read(remaining_shorts*2).unpack("n#{remaining_shorts}")
            
            ######
            
            (0..1000).each do |char|
              end_index = end_count.index { |e| e >= char }
              if start_count[end_index] <= char
                if id_range_offset[end_index] == 0
                 # p [char + id_delta[end_index], char]
                else
                 gindex = id_range_offset[(id_range_offset[end_index] / 2) + (char - start_count[end_index] )]
                 p [gindex ? glyph_ids[gindex] : 0, char]
                end
              else
                0
              end
            end
            
            ######
            
          else
            warn "TTFunk: Format #{format} not implemented, skipping"
          end
        end 
      end
    end
    
    class Head < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        data    = fh.read(20)
        @version, @font_revision, @check_sum_adjustment, @magic_number,
        @flags, @units_per_em = data.unpack("N4n2")
        
        # skip dates
        fh.read(16)
        
        data = fh.read(8)
        @x_min, @y_min, @x_max, @y_max = data.unpack("n4").map { |e| to_signed(e) } 
        
        data = fh.read(4)
        @mac_style, @lowest_rec_ppem = data.unpack("n2")
        
        data = fh.read(6)
        @font_direction_hint, @index_to_loc_format, @glyph_data_format =
          data.unpack("n3")        
      end
    end
    
    class Hhea < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        @length = info[:length]
        data   = fh.read(4)
        @version = data.unpack("N")
        
        data = fh.read(6)
        @ascent, @descent, @line_gap= data.unpack("n3").map {|e| to_signed(e) } 
        
        data = fh.read(2) 
        @advance_width_max = data.unpack("n")
        
        data = fh.read(22)
        @min_left_side_bearing, @min_right_side_bearing, @x_max_extent, 
        @caret_slope_rise, @caret_slope_run,
        @caret_offset, _, _, _, _, @metric_data_format =
        data.unpack("n11").map {|e| to_signed(e) }
        
        data = fh.read(2)
        @number_of_hmetrics = data.unpack("n").first
      end
    end
    
    class Hmtx < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        @values = []

        font.hhea.number_of_hmetrics.times do
          advance = fh.read(2).unpack("n").first
          lsb     = to_signed(fh.read(2).unpack("n").first)
          @values << [advance,lsb]
        end
        
        lsb_count = font.hhea.number_of_hmetrics - font.maxp.num_glyphs
        pattern = "n#{lsb_count}"
        @lsb = fh.read(2*lsb_count).unpack(pattern).map { |e| to_signed(e) }
      end
    end
        
    class Maxp < Table
      def initialize(fh, font, info)
        fh.pos  = info[:offset]
        @length = info[:length]
        data    = fh.read(@length)
        @version, @num_glyphs, @max_points, @max_contours, 
        @max_component_points,@max_component_contours, @max_zones, 
        @max_twilight_points, @max_storage, @max_function_defs, 
        @max_instruction_defs,@max_stack_elements, 
        @max_size_of_instructions, @max_component_elements, 
        @max_component_depth = data.unpack("Nn14")
      end
    end    
        
    class Name < Table
      def initialize(fh,info)
        fh.pos = info[:offset]
        data = fh.read(6)
        @table_start = info[:offset]
        @format, @record_count, @string_offset = data.unpack("nnn")
        parse_name_records(fh)
        parse_strings(fh)
      end
      
      def parse_name_records(fh)
        @records = {}
        @record_count.times { @records.update(parse_name_record(fh)) }
      end
      
      def parse_name_record(fh)
        data = fh.read(12).unpack("n6")
        platform, encoding, language, id, length, offset = data
        { id => { 
            :platform => platform, :encoding => encoding, 
            :language => language, :length   => length,
            :offset   => offset } }
      end
      
      def parse_strings(fh)
        @strings = @records.inject({}) do |s,v|
          id, options = v
          
          fh.pos = @table_start + @string_offset + options[:offset]
          s.merge(id => fh.read(options[:length]).delete("\000"))
        end
      end
      
      def name_data 
        [:copyright, :font_family, :font_subfamily, :unique_subfamily_id,
         :full_name, :name_table_version, :postscript_name, :trademark_notice,
         :manufacturer_name, :designer, :description, :vendor_url,
         :designer_url, :license_description, :license_info_url ]
       end
        
 
      def method_missing(*args,&block)
        if name_data.include?(args.first)
          @strings[name_data.index(args.first)]
        else
          super
        end
      end
    end
    
    class Directory < Table
      def initialize(fh)
        @scaler_type, @table_count, @search_rage,
        @entry_selector, @range_shift = fh.read(12).unpack("Nnnnn")
        parse_table_list(fh)
      end
      
      def parse_table_list(fh)
        first_table = parse_table(fh)
        @tables = first_table
        offset = first_table[first_table.keys.first][:offset]

        @tables.update(parse_table(fh)) while fh.pos < offset
      end
      
      def parse_table(fh)
        tag, checksum, offset, length = fh.read(16).unpack("a4NNN")
        { tag => { 
            :checksum => checksum, :offset => offset, :length => length } }
      end    
    end
    
    def method_missing(*args, &block)
      var = "@#{args.first}"
      instance_variables.include?(var) ? instance_variable_get(var) : super
    end
    
    private
    
    def to_signed(n, length=16)
      max = 2**length-1
      mid = 2**(length-1)
      (n>=mid) ? -((n ^ max) + 1) : n
    end
      
  end
end