require 'spec_helper'
require 'ttfunk/bin_utils'

RSpec.describe TTFunk::BinUtils do
  let(:bit_width) { 8 }

  describe '.stitch_int' do
    it 'composes an int from a series of bytes of a given width' do
      result = described_class.stitch_int(
        [0b01001100, 0b11010001], bit_width: bit_width
      )

      expect(result).to eq(0b1101000101001100)
    end
  end

  describe '.slice_int' do
    it 'breaks down an int into a series of segments of the given bit width' do
      result = described_class.slice_int(
        0b1101000101001100, bit_width: bit_width, slice_count: 2
      )

      expect(result).to eq([0b01001100, 0b11010001])
    end
  end
end
