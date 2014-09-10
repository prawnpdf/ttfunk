require 'set'
require_relative 'base'

module TTFunk
  module Subset
    class Unicode < Base
      def initialize(original)
        super
        @subset = Set.new
      end

      def unicode?
        true
      end

      def to_unicode_map
        @subset.inject({}) { |map, code| map[code] = code; map }
      end

      def use(character)
        @subset << character
      end

      def covers?(character)
        true
      end

      def includes?(character)
        @subset.includes(character)
      end

      def from_unicode(character)
        character
      end

      protected

        def new_cmap_table(options)
          mapping = @subset.inject({}) { |map, code| map[code] = unicode_cmap[code]; map }
          TTFunk::Table::Cmap.encode(mapping, :unicode)
        end

        def original_glyph_ids
          ([0] + @subset.map { |code| unicode_cmap[code] }).uniq.sort
        end
    end
  end
end
