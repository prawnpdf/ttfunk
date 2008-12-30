module TTFunk  
  class Table
    class Cmap < Table
      attr_reader :version
      attr_reader :tables

      def self.encode(charmap, encoding)
        result = Cmap::Subtable.encode(charmap, encoding)

        # pack 'version' and 'table-count'
        result[:table] = [0, 1, result.delete(:subtable)].pack("nnA*")
        return result
      end

      def unicode
        @unicode ||= @tables.select { |table| table.unicode? }
      end

      private

        def parse!
          @version, table_count = read(4, "nn")
          @tables = []

          table_count.times do
            @tables << Cmap::Subtable.new(file, offset)
          end
        end
    end
    
  end
end

require 'ttfunk/table/cmap/subtable'
