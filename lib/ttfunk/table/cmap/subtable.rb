require 'ttfunk/reader'

module TTFunk
  class Table
    class Cmap
      class Subtable
        include Reader

        attr_reader :platform_id
        attr_reader :encoding_id
        attr_reader :format

        ENCODING_MAPPINGS = {
          :mac_roman    => { :platform_id => 1, :encoding_id => 0 },
          # use microsoft unicode, instead of generic unicode, for optimal windows support
          :unicode      => { :platform_id => 3, :encoding_id => 1 }
        }

        def self.encode(charmap, encoding)
          case encoding
          when :mac_roman
            result = Format00.encode(charmap)
          when :unicode
            result = Format04.encode(charmap)
          else
            raise NotImplementedError, "encoding #{encoding.inspect} is not supported"
          end

          mapping = ENCODING_MAPPINGS[encoding]

          # platform-id, encoding-id, offset
          result[:subtable] = [mapping[:platform_id], mapping[:encoding_id],
            12, result[:subtable]].pack("nnNA*")

          return result
        end

        def initialize(file, table_start)
          @file = file
          @platform_id, @encoding_id, @offset = read(8, "nnN")
          @offset += table_start

          parse_from(@offset) do
            @format = read(2, "n").first

            case @format
              when 0 then extend(TTFunk::Table::Cmap::Format00)
              when 4 then extend(TTFunk::Table::Cmap::Format04)
            end

            parse_cmap!
          end
        end

        def unicode?
          platform_id == 3 && encoding_id == 1 && format == 4 ||
          platform_id == 0 && format == 4
        end

        def supported?
          false
        end

        def [](code)
          raise NotImplementedError, "cmap format #{@format} is not supported"
        end

        private

          def parse_cmap!
            # do nothing...
          end
      end
    end
  end
end

require 'ttfunk/table/cmap/format00'
require 'ttfunk/table/cmap/format04'
