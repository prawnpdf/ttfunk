require 'set'
require 'ttfunk/subset/base'
require 'ttfunk/encoding/mac_roman'

module TTFunk
  module Subset
    class MacRoman < Base
      def initialize(original)
        super
        @subset = Array.new(256)
      end

      def use(character)
        @subset[Encoding::MacRoman::FROM_UNICODE[character]] = character
      end

      def covers?(character)
        Encoding::MacRoman.covers?(character)
      end

      def includes?(character)
        code = Encoding::MacRoman::FROM_UNICODE[character]
        code && @subset[code]
      end

      def from_unicode(character)
        Encoding::MacRoman::FROM_UNICODE[character]
      end

      protected

        def new_cmap_table(options)
          mapping = {}
          @subset.each_with_index do |unicode, roman|
            mapping[roman] = unicode_cmap[unicode] if roman
          end

          TTFunk::Table::Cmap.encode(mapping, :mac_roman)
        end

        def original_glyph_ids
          ([0] + @subset.map { |unicode| unicode && unicode_cmap[unicode] }).compact.uniq.sort
        end
    end
  end
end
