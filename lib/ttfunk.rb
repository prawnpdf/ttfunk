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
      tables.each do |t|
        t = t.to_s
        define_method t do
          var = "@#{t}"
          if ivar = instance_variable_get(var) 
            return ivar  
          else
            open_file do |fh| 
              instance_variable_set(var, 
                Table.const_get(t.capitalize).new(fh, directory_info(t)))
            end
          end
        end
      end
    end
    
    def directory_info(table)
      directory.tables[table]
    end
    
    attr_reader :directory
    has_tables :head, :hhea
  end
  
  class Table 
    
    class Head < Table
      def initialize(fh, info)
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
      def initialize(fh,info)
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