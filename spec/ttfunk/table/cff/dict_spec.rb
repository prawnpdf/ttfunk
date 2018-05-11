require 'spec_helper'
require 'ttfunk/table/cff/dict'

RSpec.describe TTFunk::Table::Cff::Dict do
  test_cases = {
    # negative 1-byte int, positive 1-byte int, operator 5
    [0x6B, 0xF0, 0x05] => { 5 => [-32, 101] },

    # positive 2-byte ints, operator 6
    [0xF7, 0x02, 0xF8, 0x7B, 0xFA, 0x94, 0x06] => { 6 => [110, 487, 1024] },

    # negative 2-byte ints, operator 7
    [0xFB, 0x02, 0xFC, 0x7B, 0xFE, 0x94, 0x07] => { 7 => [-110, -487, -1024] },

    # negative 3-byte int, positive 3-byte int, operator 8
    [0x1C, 0x84, 0xB8, 0x1C, 0x76, 0x15, 0x08] => { 8 => [-31_560, 30_229] },

    # negative 4-byte int, positive 4-byte int, operator 9
    [0x1D, 0xBC, 0x92, 0x6A, 0xE8, 0x1D, 0x55, 0x4F, 0x3A, 0xD4, 0x09] => {
      9 => [-1_131_255_064, 1_431_255_764]
    },

    # negative float with no exponent, operator 10
    [0x1E, 0xE2, 0xA2, 0x5F, 0x0A] => { 10 => [-2.25] },

    # positive float with no exponent, operator 10
    [0x1E, 0x2A, 0x25, 0xFF, 0x0A] => { 10 => [2.25] },

    # positive float with negative exponent, operator 11
    [0x1E, 0x0A, 0x14, 0x05, 0x41, 0xC3, 0xFF, 0x0B] => {
      11 => [TTFunk::SciForm.new(0.140541, -3)]
    },

    # positive float with positive exponent, operator 11
    [0x1E, 0x0A, 0x14, 0x05, 0x41, 0xB3, 0xFF, 0x0B] => {
      11 => [TTFunk::SciForm.new(0.140541, 3)]
    }
  }

  test_cases.each_with_index do |(bytes, decoded_values), idx|
    context "test case #{idx}" do
      subject do
        io = StringIO.new(bytes.pack('C*'))
        described_class.new(
          TestFile.new(io), 0, bytes.length
        )
      end

      it 'parses correctly' do
        decoded_values.each do |operand, operators|
          expect(subject[operand]).to eq(operators)
        end
      end

      it 'encodes correctly' do
        expect(subject.encode.bytes).to eq(bytes)
      end
    end
  end

  it 'raises an error if an invalid operand is supplied' do
    # this is the invalid sci form operand "0." followed by the operator 5
    data = [0x1E, 0x0A, 0xFF, 0x05]
    file = TestFile.new(StringIO.new(data.pack('C*')))

    expect { described_class.new(file, 0, data.length) }.to raise_error(
      described_class::InvalidOperandError
    )
  end

  it 'raises an error if too many operands are supplied' do
    data = [0x6B] * (described_class::MAX_OPERANDS + 1)
    data << 0x05 # operator
    file = TestFile.new(StringIO.new(data.pack('C*')))

    expect { described_class.new(file, 0, data.length) }.to raise_error(
      described_class::TooManyOperandsError
    )
  end
end
