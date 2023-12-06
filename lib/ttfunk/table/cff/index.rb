# frozen_string_literal: true

module TTFunk
  class Table
    class Cff < TTFunk::Table
      class Index < TTFunk::SubTable
        include Enumerable

        def [](index)
          return if index >= items_count

          entry_cache[index] ||=
            decode_item(
              index,
              data_reference_offset + offsets[index],
              offsets[index + 1] - offsets[index]
            )
        end

        def each(&block)
          return to_enum(__method__) unless block

          items_count.times do |i|
            yield self[i]
          end
        end

        def items_count
          items.length
        end

        def encode(*args)
          new_items = encode_items(*args)

          if new_items.empty?
            return [0].pack('n')
          end

          if new_items.length > 0xffff
            raise Error, 'Too many items in a CFF index'
          end

          offsets_array =
            new_items
              .each_with_object([1]) do |item, offsets|
                offsets << offsets.last + item.length
              end

          offset_size = (offsets_array.last.bit_length / 8.0).ceil

          offsets_array.map! { |offset| encode_offset(offset, offset_size) }

          EncodedString.new.concat(
            [new_items.length, offset_size].pack('nC'),
            *offsets_array,
            *new_items
          )
        end

        private

        attr_reader :items, :offsets, :data_reference_offset

        def entry_cache
          @entry_cache ||= {}
        end

        # Returns an array of EncodedString elements (plain strings,
        # placeholders, or EncodedString instances). Each element is supposed to
        # represent an encoded item.
        #
        # This is the place to do all the filtering, reordering, or individual
        # item encoding.
        #
        # It gets all the arguments `encode` gets.
        def encode_items(*)
          items
        end

        # By default do nothing
        def decode_item(index, _offset, _length)
          items[index]
        end

        def encode_offset(offset, offset_size)
          case offset_size
          when 1
            [offset].pack('C')
          when 2
            [offset].pack('n')
          when 3
            [offset].pack('N')[1..]
          when 4
            [offset].pack('N')
          end
        end

        def parse!
          @entry_cache = {}

          num_entries = read(2, 'n').first

          if num_entries.zero?
            @length = 2
            @items = []
            return
          end

          offset_size = read(1, 'C').first

          @offsets =
            Array.new(num_entries + 1) do
              unpack_offset(io.read(offset_size), offset_size)
            end

          @data_reference_offset = table_offset + 3 + offsets.length * offset_size - 1

          @length =
            2 + # num entries
            1 + # offset size
            offsets.length * offset_size + # offsets
            offsets.last - 1 # items

          @items =
            offsets.each_cons(2).map do |offset, next_offset|
              io.read(next_offset - offset)
            end
        end

        def unpack_offset(offset_data, offset_size)
          padding = "\x00" * (4 - offset_size)
          (padding + offset_data).unpack1('N')
        end
      end
    end
  end
end
