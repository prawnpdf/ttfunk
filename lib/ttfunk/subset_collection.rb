require 'ttfunk/subset'

module TTFunk
  class SubsetCollection
    def initialize(original)
      @original = original
      @subsets = [Subset.for(@original, :mac_roman)]
    end

    def [](subset)
      @subsets[subset]
    end

    # +characters+ should be an array of UTF-16 characters
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

    # +characters+ should be an array of UTF-16 characters. Returns
    # an array of subset chunks, where each chunk is another array of
    # two elements. The first element is the subset number, and the
    # second element is the string of characters to render with that
    # font subset. The strings will be encoded for their subset font,
    # and so may not look (in the raw) like what was passed in, but
    # they will render correctly with the indicated subset font.
    def encode(characters)
      return [] if characters.empty?

      # TODO: probably would be more optimal to nix the #use method,
      # and merge it into this one, so it can be done in a single
      # pass instead of two passes.
      use(characters)

      parts = []
      current_subset = 0
      current_char = 0
      char = characters[current_char]

      loop do
        while @subsets[current_subset].includes?(char)
          char = @subsets[current_subset].from_unicode(char)

          if parts.empty? || parts.last[0] != current_subset
            parts << [current_subset, char.chr]
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
  end
end
