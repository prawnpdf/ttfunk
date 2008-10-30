class TTFunk
  class File
    def initialize(file)
      ::File.open(file,"rb") do |fh|
        @directory = Table::Directory.new(fh)
      end
    end
    
    attr_reader :directory
  end
  
  class Table 
    
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
    
  end
end