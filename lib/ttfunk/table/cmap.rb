# frozen_string_literal: true

module TTFunk
  class Table
    # Character to Glyph Index Mapping (`cmap`) table.
    class Cmap < Table
      # Table version.
      # @return [Integer]
      attr_reader :version

      # Encoding tables.
      # @return [Array<TTFunk::Table::Cmap::Subtable>]
      attr_reader :tables

      # Encode table.
      #
      # @param charmap [Hash{Integer => Integer}]
      # @param encoding [Symbol]
      # @return [Hash]
      def self.encode(charmap, encoding)
        # Encode the primary (unicode) subtable
        unicode_result = Cmap::Subtable.encode(charmap, encoding)

        # Also encode Mac Roman (platform 1, encoding 0) so Illustrator can
        # resolve glyph IDs back to characters when editing embedded font text.
        # Without this subtable, Illustrator falls back to treating glyph IDs
        # as raw character codes, producing gobbledygook.
        # Only codepoints <= 0xFF can be represented in Mac Roman.
        mac_charmap = charmap.select { |code, _| code <= 0xFF }
        mac_result = Cmap::Subtable.encode(mac_charmap, :mac_roman)

        # Strip the 8-byte record header (platformID nn + encodingID nn + offset N)
        # that Subtable.encode prepends, leaving only the raw cmap format data.
        mac_raw     = mac_result[:subtable][8..]
        unicode_raw = unicode_result[:subtable][8..]

        # cmap header: version(2) + numTables(2) = 4 bytes
        # Each encoding record: platformID(2) + encodingID(2) + offset(4) = 8 bytes
        # Two records = 16 bytes
        # Total before subtable data = 4 + 16 = 20 bytes
        header_and_records_size = 4 + (2 * 8)

        mac_offset     = header_and_records_size
        unicode_offset = header_and_records_size + mac_raw.bytesize

        table = [0, 2].pack('nn')                    # version=0, numTables=2
        table += [1, 0, mac_offset].pack('nnN')      # Mac Roman record
        table += [3, 1, unicode_offset].pack('nnN')  # Windows Unicode record
        table += mac_raw                              # Format 0 data
        table += unicode_raw                          # Format 4 data

        unicode_result.merge(table: table)
      end

      # Get Unicode encoding records.
      #
      # @return [Array<TTFunk::Table::Cmap::Subtable>]
      def unicode
        @unicode ||=
          @tables
            .select { |table| table.unicode? && table.supported? }
            .sort { |a, b| b.format <=> a.format }
      end

      private

      def parse!
        @version, table_count = read(4, 'nn')
        @tables =
          Array.new(table_count) do
            Cmap::Subtable.new(file, offset)
          end
      end
    end
  end
end

require_relative 'cmap/subtable'
