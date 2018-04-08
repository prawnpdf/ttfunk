module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Index < TTFunk::SubTable
        include Enumerable

        # number of objects in the index
        attr_reader :count

        # offset array element size
        attr_reader :offset_size

        def [](index)
          @data[index]
        end

        def each
          return to_enum(__method__) unless block_given?
          count.times { |i| yield self[i] }
        end

        def encode
          result = []

          entries = each_with_object([]).with_index do |(entry, ret), index|
            new_entry = block_given? ? yield(entry, index) : entry
            ret << new_entry if new_entry
          end

          # "An empty INDEX is represented by a count field with a 0 value and
          # no additional fields. Thus, the total size of an empty INDEX is 2
          # bytes."
          result << [entries.size].pack('n')
          return result.join if entries.empty?

          offset_size = (Math.log2(entries.size) / 8.0).round + 1
          result << [offset_size].pack('C')
          data_offset = 1

          data = []

          entries.each do |entry|
            result << encode_offset(data_offset, offset_size)
            data << entry
            data_offset += entry.bytesize
          end

          unless entries.empty?
            result << encode_offset(data_offset, offset_size)
          end

          result.join + data.join
        end

        private

        def encode_offset(offset, offset_size)
          case offset_size
          when 1
            [offset].pack('C')
          when 2
            [offset].pack('n')
          when 3
            [offset].pack('N')[1..-1]
          when 4
            [offset].pack('N')
          end
        end

        def parse!
          @count = read(2, 'n').first

          if count == 0
            @length = 2
            @data = []
            return
          end

          # read an extra byte to get rid of the first offset,
          # which is always 1
          @offset_size, = read(2, 'C')
          raw_offsets = io.read(count * offset_size)

          offsets = [0] + Array.new(count) do |idx|
            start = offset_size * idx
            finish = offset_size * (idx + 1)
            unpack_offset(raw_offsets[start...finish]) - 1
          end

          raw_data = io.read(offsets.last)
          @data = offsets.each_cons(2).map do |start_offset, next_start_offset|
            raw_data[start_offset...next_start_offset]
          end

          @length = 4 + raw_offsets.size + raw_data.size
        end

        def unpack_offset(offset_data)
          padding = "\x00" * (4 - offset_size)
          (padding + offset_data).unpack('N').first
        end
      end
    end
  end
end
