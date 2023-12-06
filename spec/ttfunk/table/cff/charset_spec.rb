# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::Charset do
  let(:font) { TTFunk::File.open(font_path) }
  let(:charset) { font.cff.top_index[0].charset }

  describe 'parsing and element access' do
    context 'with an ID-based charset' do
      let(:charset_id) { 0 } # iso_adobe
      let(:charset) do
        described_class.new(nil, TestFile.new(StringIO.new), charset_id, 0)
      end

      it 'includes all the entries from the expert charset' do
        expect(charset.to_a).to eq(
          ['.notdef'] + described_class.strings_for_charset_id(charset_id)
        )
      end
    end

    context 'with an array-formatted charset' do
      let(:font_path) { test_font('Exo-Regular', :otf) }

      it 'includes entries for all the glyphs in the font' do
        # From the spec: There is one less element in the glyph name array than
        # nGlyphs (i.e. charstrings count) because the .notdef glyph name is
        # omitted.
        expect(charset.items_count).to(
          eq(font.cff.top_index[0].charstrings_index.items_count - 1)
        )
      end

      it 'parses the entries correctly' do
        strings = charset.to_a

        # these should come from the set of "standard" strings
        expect(strings[0..6]).to eq(
          %w[.notdef uni000D space exclam quotedbl numbersign dollar]
        )

        # these should come from the strings index
        expect(strings[-6..]).to eq(
          %w[
            endash.smcp emdash.smcp parenleft.alt parenright.alt
            parenleft.smcp parenright.smcp
          ]
        )
      end
    end

    context 'with an 8-bit range-formatted charset' do
      let(:font_path) { test_font('ComicJens-Regular', :otf) }

      it 'includes entries for all the glyphs in the font' do
        # From the spec: There is one less element in the glyph name array than
        # nGlyphs (i.e. charstrings count) because the .notdef glyph name is
        # omitted.
        expect(charset.items_count).to(
          eq(font.cff.top_index[0].charstrings_index.items_count - 1)
        )
      end

      it 'parses the entries correctly' do
        strings = charset.to_a

        # these should come from the set of "standard" strings
        expect(strings[0..6]).to eq(
          %w[.notdef .null CR space exclam quotedbl numbersign]
        )

        # these should come from the strings index
        expect(strings[-6..]).to eq(
          %w[r_r s_s t_t w_w_w zero_seven zero_zero]
        )
      end
    end

    context 'with a 16-bit range-formatted charset' do
      let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

      it 'includes entries for all the glyphs in the font' do
        # From the spec: There is one less element in the glyph name array than
        # nGlyphs (i.e. charstrings count) because the .notdef glyph name is
        # omitted.
        expect(charset.items_count).to(
          eq(font.cff.top_index[0].charstrings_index.items_count - 1)
        )
      end

      it 'parses the entries correctly' do
        strings = charset.to_a

        # these should come from the set of "standard" strings
        expect(strings[0..6]).to eq(
          %w[.notdef space exclam quotedbl numbersign dollar percent]
        )

        # These should come from the strings index. This particular font is
        # curious however in that most of the glyphs do not have a corresponding
        # entry in the strings index even though the charset indicates they are
        # all covered. This was probably done to cut down on file size since
        # the font contains ~65k glyphs. Moreover, most of the glyphs in the
        # font are Chinese characters which may not have useful descriptions.
        # For example, the Unicode/CLDR data for most Chinese characters simply
        # contains the description "CJK Ideograph."
        expect(strings[-6..]).to eq(
          [nil, nil, nil, nil, nil, nil]
        )
      end
    end
  end

  describe '#encode' do
    let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
    let(:encoded) { charset.encode(charmap) }

    context 'when the subset contains non-sequential SIDs' do
      let(:charmap) do
        # the idea here is to demonstrate that non-sequental SIDs can sometimes
        # be more compactly represented as individual elements as opposed to
        # ranges (supposed to be new => old glyph IDs)
        {
          0x20 => { old: 1, new: 1 },
          0x23 => { old: 4, new: 4 },
          0x29 => { old: 10, new: 10 },
          0x2d => { old: 14, new: 14 },
          0x2e => { old: 15, new: 15 },
          0x34 => { old: 21, new: 21 }
        }
      end

      it 'encodes using the array-based format' do
        expect(encoded.bytes[0]).to eq(0)
      end

      it 'encodes correctly' do
        # format (0x00), SIDs (2 bytes each)
        expect(encoded.bytes).to eq(
          [
            0x00, 0x00, 0x01, 0x00, 0x04, 0x00, 0x0A,
            0x00, 0x0E, 0x00, 0x0F, 0x00, 0x15
          ]
        )
      end
    end

    context 'when the subset contains few sequential SIDs' do
      let(:charmap) do
        # i.e. the first 20 characters, in order
        # (supposed to be new => old glyph IDs)
        Hash[(1..20).map { |i| [0x20 + i, { old: i, new: i }] }]
      end

      it 'encodes using the 8-bit range-based format' do
        expect(encoded.bytes[0]).to eq(1)
      end

      it 'encodes correctly' do
        # format (0x01), start SID (0x00, 0x01), rest (0x02, 0x13)
        expect(encoded.bytes).to eq([0x01, 0x00, 0x01, 0x13])
      end
    end

    context 'when the subset contains many sequential SIDs' do
      let(:charmap) do
        # we want to get a 2-byte range to demonstrate the 16-bit format
        # (supposed to be new => old glyph IDs)
        Hash[(1..2**10).map { |i| [0x20 + i, { old: i, new: i }] }]
      end

      it 'encodes using the 16-bit range-based format' do
        expect(encoded.bytes[0]).to eq(2)
      end

      it 'encodes correctly' do
        # format (0x02), start SID (0x00, 0x01), rest (0x03, 0xFF)
        expect(encoded.bytes).to eq([0x02, 0x00, 0x01, 0x03, 0xFF])
      end
    end
  end
end
