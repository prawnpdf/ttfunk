require 'ttfunk/subset'

module TTFunk
  class SubsetCollection
    def initialize(original)
      @original = original
      @subsets = [Subset.for(@original, :mac_roman)]
    end

    def use(characters)
      characters.each do |char|
        covered = false
        @subsets.each_with_index do |subset, i|
          if subset.covers?(char)
            subset.use(char)
            covered = true
            break
          end
        end

        if !covered
          @subsets << Subset.for(@original, :unicode_8bit)
          @subsets.last.use(char)
        end
      end
    end

    def convert_text(characters)
      parts = []
      current_subset = 0
      current_char = 0
      char = characters[current_char]

      loop do
        while @subsets[current_subset].includes?(char)
          char = @subsets[current_subset].from_unicode(char)

          if parts.empty? || parts.last[0] != current_subset
            parts << [current_subset, [char]]
          else
            parts.last[1] << char
          end

          current_char += 1
          return parts if current_char >= characters.length
          char = characters[current_char]
        end

        current_subset = (current_subset + 1) % @subsets.length
      end
    end

    def encode_subsets(options={})
      @subsets.map { |subset| subset.encode(options) }
    end
  end
end
