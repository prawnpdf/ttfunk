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

  describe '.twos_comp_to_int' do
    it "converts a two's complement number to an integer" do
      expect(described_class.twos_comp_to_int(0b10101001, bit_width: 8)).to(
        eq(-0b01010111)
      )
    end

    it "returns the original number if the number isn't negative" do
      expect(described_class.twos_comp_to_int(0b01101001, bit_width: 8)).to(
        eq(0b01101001)
      )
    end
  end

  describe '.rangify' do
    subject { described_class.rangify(values) }

    context 'with a simple run of sequential values' do
      let(:values) { [1, 2, 3, 4] }

      it { is_expected.to eq([[1, 3]]) }
    end

    context 'with multiple runs' do
      let(:values) { [1, 2, 3, 4, 6, 8, 9, 10] }

      it { is_expected.to eq([[1, 3], [6, 0], [8, 2]]) }
    end
  end
end
