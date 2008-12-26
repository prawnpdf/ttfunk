require 'ttfunk/table'

module TTFunk
  class Table
    class Kern < Table
      attr_reader :version
      attr_reader :tables

      private

        def parse!
          @version, num_tables = read(4, "n*")
          @tables = []

          if @version == 1 # Mac OS X fonts
            @version = (@version << 16) + num_tables
            num_tables = read(4, "N").first
            parse_version_1_tables(num_tables)
          else
            parse_version_0_tables(num_tables)
          end
        end

        def parse_version_0_tables(num_tables)
          num_tables.times do # MS fonts
            version, length, coverage = read(6, "n*")
            format = coverage >> 8

            add_table format, :version => version, :length => length,
              :coverage => coverage, :data => handle.read(length-6),
              :vertical => (coverage & 0x1 == 0),
              :minimum => (coverage & 0x2 != 0),
              :cross => (coverage & 0x4 != 0),
              :override => (coverage & 0x8 != 0)
          end
        end

        def parse_version_1_tables(num_tables)
          num_tables.times do
            length, coverage, tuple_index = read(8, "Nnn")
            format = coverage & 0x0FF

            add_table format, :length => length, :coverage => coverage,
              :tuple_index => tuple_index, :data => handle.read(length-8),
              :vertical => (coverage & 0x8000 != 0),
              :cross => (coverage & 0x4000 != 0),
              :variation => (coverage & 0x2000 != 0)
          end
        end

        def add_table(format, attributes={})
          if format == 0
            @tables << Kern::Format0.new(attributes)
          else
            # silently ignore unsupported kerning tables
          end
        end
    end
  end
end

require 'ttfunk/table/kern/format0'
