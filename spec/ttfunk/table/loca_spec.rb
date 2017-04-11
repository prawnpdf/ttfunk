require 'spec_helper'
require 'ttfunk/table/loca'

RSpec.describe TTFunk::Table::Loca do
  describe '.encode' do
    it 'properly encodes short aligned offsets' do
      result = described_class.encode([0, 2, 4])

      expect(result[:type]).to eq(0)
      expect(result[:table].bytes).to eq [
        0x00, 0x00,
        0x00, 0x01,
        0x00, 0x02
      ]
    end

    it 'properly encodes short-is aligned offsets' do
      result = described_class.encode([0, 0x1FFFE])

      expect(result[:type]).to eq(0)
      expect(result[:table].bytes).to eq [
        0x00, 0x00,
        0xFF, 0xFF
      ]
    end

    it 'properly encodes short misaligned offsets' do
      result = described_class.encode([0, 2, 3])

      expect(result[:type]).to eq(1)
      expect(result[:table].bytes).to eq [
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x02,
        0x00, 0x00, 0x00, 0x03
      ]
    end

    it 'properly encodes long offsets' do
      result = described_class.encode([0, 0x1FFFF])

      expect(result[:type]).to eq(1)
      expect(result[:table].bytes).to eq [
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x01, 0xFF, 0xFF
      ]
    end
  end
end
