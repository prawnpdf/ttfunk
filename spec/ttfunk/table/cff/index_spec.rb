require 'spec_helper'
require 'ttfunk/table/cff/index'

RSpec.describe TTFunk::Table::Cff::Index do
  test_cases = {
    [
      # count
      0x00, 0x03,
      # offset len
      0x01,
      # offsets
      0x01, 0x02, 0x03, 0x04,
      # data
      0xA,
      0xB,
      0xC
    ] => [[10], [11], [12]],

    [
      # count
      0x00, 0x03,
      # offset len
      0x01,
      # offsets
      0x01, 0x03, 0x07, 0x08,
      # data
      0x11, 0x22,
      0x33, 0x44, 0x55, 0x66,
      0x77
    ] => [[17, 34], [51, 68, 85, 102], [119]],

    [0x00, 0x00] => []
  }

  test_cases.each_with_index do |(bytes, decoded_values), idx|
    context "test case #{idx}" do
      subject do
        io = StringIO.new(bytes.pack('C*'))
        described_class.new(
          TestFile.new(io), 0, bytes.size
        )
      end

      it 'parses correctly' do
        expect(subject.map(&:bytes)).to eq(decoded_values)
      end

      it 'encodes correctly' do
        expect(subject.encode.bytes).to eq(bytes)
      end

      it 'calculates the length correctly' do
        expect(subject.length).to eq(bytes.size)
      end
    end
  end
end
