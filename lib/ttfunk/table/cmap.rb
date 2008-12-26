module TTFunk  
  class Table
    class Cmap < Table
      attr_reader :version
      attr_reader :tables

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
