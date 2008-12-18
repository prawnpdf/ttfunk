module TTFunk
  class Table
    class Directory < Table
      def initialize(fh)
        @scaler_type, @table_count, @search_range,
        @entry_selector, @range_shift = fh.read(12).unpack("Nnnnn")
        
        @tables = {}
        @table_count.times { |i| @tables.update(parse_table(fh)) }
      end
  
      def parse_table(fh)
        tag, checksum, offset, length = fh.read(16).unpack("a4NNN")
        { tag => { 
            :checksum => checksum, :offset => offset, :length => length } }
      end    
    end
  end
end
