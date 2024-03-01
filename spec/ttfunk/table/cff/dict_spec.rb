# frozen_string_literal: true

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
      9 => [-1_131_255_064, 1_431_255_764],
    },

    # negative float with no exponent, operator 10
    [0x1E, 0xE2, 0xA2, 0x5F, 0x0A] => { 10 => [-2.25] },

    # positive float with no exponent, operator 10
    [0x1E, 0x2A, 0x25, 0xFF, 0x0A] => { 10 => [2.25] },

    # positive float with negative exponent, operator 11
    [0x1E, 0x0A, 0x14, 0x05, 0x41, 0xC3, 0xFF, 0x0B] => {
      11 => [TTFunk::SciForm.new(0.140541, -3)],
    },

    # positive float with positive exponent, operator 11
    [0x1E, 0x0A, 0x14, 0x05, 0x41, 0xB3, 0xFF, 0x0B] => {
      11 => [TTFunk::SciForm.new(0.140541, 3)],
    },

    # Float with a missing exponent, operator 1
    [0x1E, 0x0A, 0x1F, 0x01] => { 1 => [TTFunk::SciForm.new(0.1, 0)] },
  }

  test_cases.each_with_index do |(bytes, decoded_values), idx|
    context "with example #{idx}" do
      subject(:dict) do
        io = StringIO.new(bytes.pack('C*'))
        described_class.new(TestFile.new(io), 0, bytes.length)
      end

      it 'parses correctly' do
        decoded_values.each do |operand, operators|
          expect(dict[operand]).to eq(operators)
        end
      end

      it 'encodes correctly' do
        expect(dict.encode.bytes).to eq(bytes)
      end
    end
  end

  it 'raises an error if an invalid operand is supplied' do
    # this is the invalid sci form operand "0." followed by the operator 5
    data = [0x1E, 0x0A, 0xFF, 0x05]
    file = TestFile.new(StringIO.new(data.pack('C*')))

    expect { described_class.new(file, 0, data.length) }.to raise_error(described_class::InvalidOperandError)
  end

  it 'raises an error if too many operands are supplied' do
    data = [0x6B] * (described_class::MAX_OPERANDS + 1)
    data << 0x05 # operator
    file = TestFile.new(StringIO.new(data.pack('C*')))

    expect { described_class.new(file, 0, data.length) }.to raise_error(described_class::TooManyOperandsError)
  end

  it 'allows addition of entries' do
    dict = described_class.new(TestFile.new(StringIO.new('')), 0, 0)

    dict[1] = 42
    dict[1201] = [43, 44]

    expect(dict.encode).to eq("\xB5\x01\xb6\xb7\x0c\x01".b)
  end

  it 'allows replacement of entries' do
    dict = described_class.new(TestFile.new(StringIO.new("\xB5\x01\xb6\xb7\x0c\x01".b)), 0, 6)

    dict[1] = 0

    expect(dict.encode).to eq("\x8b\x01\xb6\xb7\x0c\x01".b)
  end

  it 'uses a stable encoding order' do
    dict1 = described_class.new(TestFile.new(StringIO.new('')), 0, 0)
    dict2 = described_class.new(TestFile.new(StringIO.new('')), 0, 0)

    dict1[1] = 1
    dict1[2] = 2

    dict2[2] = 2
    dict2[1] = 1

    expect(dict1.encode).to eq(dict2.encode)
  end
end
