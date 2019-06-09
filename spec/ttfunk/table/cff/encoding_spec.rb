# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::Encoding do
  let(:font) { TTFunk::File.open(font_path) }
  let(:encoding) { font.cff.top_index[0].encoding }

  describe 'parsing and element access' do
    context 'with a predefined encoding (standard)' do
      let(:font_path) { test_font('Exo-Regular', :otf) }
      let(:encoding_id) { described_class::STANDARD_ENCODING_ID }

      it 'includes all the entries from the standard encoding' do
        expect(encoding.to_a).to eq(
          [0] + described_class.codes_for_encoding_id(encoding_id)
        )
      end
    end

    context 'with a range-formatted encoding' do
      let(:font_path) { test_font('AlbertTextBold', :otf) }

      it 'parses the entries correctly' do
        expect(encoding.to_a[0..8]).to eq(
          [0, 26, 27, 28, 29, 30, 31, 32, 33]
        )
      end
    end
  end

  describe '#encode' do
    let(:font_path) { test_font('AlbertTextBold', :otf) }
    let(:encoded) { encoding.encode(subset_mapping) }

    context 'when the subset contains non-sequential codes' do
      let(:subset_mapping) do
        # the idea here is to demonstrate that non-sequental codes can
        # sometimes be more compactly represented as individual elements
        # as opposed to ranges (supposed to be new => old glyph IDs)
        { 1 => 1, 4 => 4, 10 => 10, 14 => 14, 15 => 15, 21 => 21 }
      end

      it 'encodes using the array-based format' do
        expect(encoded.bytes[0]).to eq(0)
      end

      it 'encodes correctly' do
        # format (0x00), codes (1 byte each)
        expect(encoded.bytes).to eq(
          [
            0,
            subset_mapping.count,
            *subset_mapping.map { |old_gid, _| encoding[old_gid] }
          ]
        )
      end

      # unfortunately I haven't been able to find an example font that defines
      # an array-based encoding, so this is the closest we can get to testing
      # that the parsing logic works for arrays
      # rubocop: disable RSpec/AnyInstance
      it 're-parses successfully' do
        file = TestFile.new(StringIO.new(encoded))
        fake_offset = 100

        # To calculate the offset of the encoding table, the Encoding class
        # adds its own table offset to the CFF offset. Since we're testing the
        # encoding logic in isolation, there's no CFF table and therefore no CFF
        # offset. Furthermore, we pass a value for offset_or_id (i.e.
        # fake_offset above) that's greater than the IDs used to indicate a
        # predefined encoding, but which is non-zero. Since, again, we're
        # testing in isolation, the parser needs to start at position 0. Long
        # story short: we need to zero out both values to run the test.
        allow_any_instance_of(described_class).to(
          receive(:offset).and_return(0)
        )

        allow(font.cff.top_index[0]).to receive(:cff_offset).and_return(0)

        new_encoding = described_class.new(
          font.cff.top_index[0], file, fake_offset, encoded.length
        )

        expect(new_encoding.to_a).to eq([0, 26, 29, 35, 39, 40, 46])
      end
      # rubocop: enable RSpec/AnyInstance
    end

    context 'when the subset contains sequential codes' do
      let(:subset_mapping) do
        # i.e. the first 20 characters, in order
        # (supposed to be new => old glyph IDs)
        Hash[(1..20).map { |i| [i, i] }]
      end

      it 'encodes using the range-based format' do
        expect(encoded.bytes[0]).to eq(1)
      end

      it 'encodes correctly' do
        # format (0x01), count (0x01, start code (0x1D, i.e. 26),
        # rest (0x13, i.e. 19)
        expect(encoded.bytes).to eq([0x01, 0x01, 0x1A, 0x13])
      end
    end
  end
end
