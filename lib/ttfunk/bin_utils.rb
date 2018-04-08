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

    def twos_comp_to_int(num, bit_width:)
      if num >> (bit_width - 1) == 1
        # we want all ones
        mask = (2**bit_width) - 1

        # find 2's complement, i.e. flip bits (xor with mask) and add 1
        -((num ^ mask) + 1)
      else
        num
      end
    end
  end

  BinUtils.extend(BinUtils)
end
