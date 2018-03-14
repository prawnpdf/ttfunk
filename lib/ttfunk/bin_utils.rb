module TTFunk
  module BinUtils
    # assumes big-endian
    def stitch_int(arr, bit_width:)
      value = 0

      arr.each_with_index do |element, index|
        value |= element << bit_width * index
      end

      value
    end

    # assumes big-endian
    def slice_int(value, bit_width:, slice_count:)
      mask = 2**bit_width - 1

      Array.new(slice_count) do |i|
        (value >> bit_width * i) & mask
      end
    end
  end

  BinUtils.extend(BinUtils)
end
