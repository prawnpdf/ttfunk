module TTFunk
  class Table
    class Cff < TTFunk::Table
      autoload :Dict,   'ttfunk/table/cff/dict'
      autoload :Header, 'ttfunk/table/cff/header'
      autoload :Index,  'ttfunk/table/cff/index'

      TAG = 'CFF '.freeze # the extra space is important

      attr_reader :header, :name_index

      def tag
        TAG
      end

      def encode(_mapping)
        [header.encode, name_index.encode].join
      end

      private

      def parse!
        @header = Header.new(file, offset)
        @name_index = Index.new(file, @header.table_offset + @header.length)
      end
    end
  end
end
