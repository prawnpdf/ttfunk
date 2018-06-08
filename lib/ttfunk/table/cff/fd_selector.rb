module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FdSelector < TTFunk::SubTable
        include Enumerable

        RANGE_ENTRY_SIZE = 3
        ARRAY_ENTRY_SIZE = 1

        attr_reader :top_dict, :count, :entries, :n_glyphs

        def initialize(top_dict, file, offset, length = nil)
          @top_dict = top_dict
          super(file, offset, length)
        end

        def [](glyph_id)
          case format_sym
          when :array_format
            entries[glyph_id]

          when :range_format
            if (entry = range_cache[glyph_id])
              return entry
            end

            range, entry = entries.bsearch do |rng, _|
              if rng.cover?(glyph_id)
                0
              elsif glyph_id < rng.first
                -1
              else
                1
              end
            end

            range.each { |i| range_cache[i] = entry }
            entry
          end
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        # mapping is new -> old glyph ids
        def encode(mapping)
          # get list of old GIDs in new GID order
          old_gids = mapping.keys.sort.map { |new_gid| mapping[new_gid] }
          ranges = rangify(old_gids)
          total_range_size = ranges.size * RANGE_ENTRY_SIZE
          total_array_size = old_gids.size * ARRAY_ENTRY_SIZE

          [].tap do |result|
            if total_array_size <= total_range_size
              result << [format_int(:array_format)].pack('C')
              result << old_gids.map { |old_gid| self[old_gid] }.pack('C*')
            else
              result << [format_int(:range_format), ranges.size].pack('Cn')
              ranges.each { |range| result << range.pack('nC') }

              # "A sentinel GID follows the last range element and serves to
              # delimit the last range in the array. (The sentinel GID is set
              # equal to the number of glyphs in the font. That is, its value
              # is 1 greater than the last GID in the font)."
              result << [old_gids.size].pack('n')
            end
          end.join
        end

        private

        def range_cache
          @range_cache ||= {}
        end

        def rangify(values)
          start = values.first

          [].tap do |ranges|
            values.each_cons(2) do |first, second|
              if second - first != 1 || self[first] != self[second]
                ranges << [start, self[first]]
                start = second
              end
            end

            ranges << [start, self[values.last]]
          end
        end

        def parse!
          @format = read(1, 'C').first
          @length = 1

          case format_sym
          when :array_format
            @n_glyphs = top_dict.charstrings_index.count
            data = io.read(n_glyphs)
            @length += data.bytesize
            @count = data.bytesize
            @entries = data.bytes

          when :range_format
            num_ranges = read(2, 'n').first
            ranges = Array.new(num_ranges) { read(RANGE_ENTRY_SIZE, 'nC') }

            @entries = ranges.each_cons(2).map do |first, second|
              first_gid, fd_index = first
              second_gid, = second
              [(first_gid...second_gid), fd_index]
            end

            # read the sentinel GID, otherwise known as the number of glyphs
            # in the font
            @n_glyphs = read(2, 'n').first

            last_start_gid, last_fd_index = ranges.last
            @entries << [(last_start_gid...(n_glyphs + 1)), last_fd_index]

            # +2 for sentinel GID, +2 for num_ranges
            @length += (num_ranges * RANGE_ENTRY_SIZE) + 4
            @count = entries.inject(0) { |sum, entry| sum + entry.first.size }
          end
        end

        def format_sym
          case @format
          when 0 then :array_format
          when 3 then :range_format
          else
            raise "unsupported fd select format '#{@format}'"
          end
        end

        def format_int(format_sym)
          case format_sym
          when :array_format then 0
          when :range_format then 3
          else
            raise "unsupported fd select format '#{format_sym}'"
          end
        end
      end
    end
  end
end
