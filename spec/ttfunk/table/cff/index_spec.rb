# frozen_string_literal: true

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
      0xC,
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
      0x77,
    ] => [[17, 34], [51, 68, 85, 102], [119]],

    [0x00, 0x00] => [],
  }

  describe 'decoding' do
    test_cases.each_with_index do |(bytes, decoded_values), idx|
      context "with example #{idx}" do
        subject(:index) do
          io = StringIO.new(bytes.pack('C*'))
          described_class.new(TestFile.new(io), 0, bytes.size)
        end

        it 'parses correctly' do
          expect(index.map(&:bytes)).to eq(decoded_values)
        end

        it 'encodes correctly' do
          expect(index.encode.bytes).to eq(bytes)
        end

        it 'calculates the length correctly' do
          expect(index.length).to eq(bytes.size)
        end
      end
    end
  end

  describe 'encoding' do
    it 'properly encodes items (change)' do
      inc_index_class =
        Class.new(described_class) do
          private

          def encode_items(*)
            # Increase each byte by 1
            items.map { |i| [i.unpack1('C') + 1].pack('C') }
          end
        end

      data = [
        # count
        0x00, 0x03,
        # offset len
        0x01,
        # offsets
        0x01, 0x02, 0x03, 0x04,
        # data
        0x01, 0x02, 0x03,
      ].pack('C*')

      index = inc_index_class.new(TestFile.new(StringIO.new(data)), 0, data.length)

      expect(index.encode.string).to eq("\00\03\01\01\02\03\04\02\03\04")
    end

    it 'properly encodes items (filter)' do
      dup_index_class =
        Class.new(described_class) do
          private

          def encode_items(*)
            # duplicate each item
            items.flat_map { |i| [i, i] }
          end
        end

      data = [
        # count
        0x00, 0x03,
        # offset len
        0x01,
        # offsets
        0x01, 0x02, 0x03, 0x04,
        # data
        0x01, 0x02, 0x03,
      ].pack('C*')

      index = dup_index_class.new(TestFile.new(StringIO.new(data)), 0, data.length)

      expect(index.encode.string).to eq("\00\06\01\01\02\03\04\05\06\07\01\01\02\02\03\03")
    end

    [
      { item_size: 1, data_size: 6, offset_size: 1 },
      { item_size: 0xff, data_size: 262, offset_size: 2 },
      { item_size: 0xffff, data_size: 65_544, offset_size: 3 },
      { item_size: 0xffffff, data_size: 16_777_226, offset_size: 4 },
    ].each do |params|
      it "properly encodes offset size #{params[:offset_size]}" do
        gen_index_class =
          Class.new(described_class) do
            attr_accessor :item_size

            private

            def encode_items(*)
              ["\00" * item_size]
            end
          end

        gen_index = gen_index_class.new(TestFile.new(StringIO.new("\00\00")), 0, 2)
        gen_index.item_size = params[:item_size]

        data = gen_index.encode.string

        expect(data.length).to eq params[:data_size]

        index = described_class.new(TestFile.new(StringIO.new(data)), 0, data.length)

        expect(index.items_count).to eq 1
      end
    end

    it 'raises on more items than is possible to encode' do
      gen_index_class =
        Class.new(described_class) do
          private

          def encode_items(*)
            ["\00"] * 0x10000
          end
        end

      gen_index = gen_index_class.new(TestFile.new(StringIO.new("\00\00")), 0, 2)

      expect { gen_index.encode }.to raise_error(/too many items/i)
    end
  end
end
