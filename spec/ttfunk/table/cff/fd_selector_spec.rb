require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::FdSelector do
  let(:font) { TTFunk::File.open(font_path) }
  let(:fd_selector) { font.cff.top_index[0].font_dict_selector }

  context 'with an array-formatted selector' do
    # sadly it appears the array format isn't widely used, so it's necessary to
    # test the functionality manually
    let(:io) { StringIO.new(contents) }
    let(:contents) { "\x00\x01\x02\x03\x04\x05\x06" }
    let(:entry_count) { 6 }
    let(:top_dict) { double(:top_dict, charstrings_index: charstrings_index) }
    let(:charstrings_index) { double(:charstrings_index, count: entry_count) }
    let(:fd_selector) do
      described_class.new(top_dict, TestFile.new(io), 0, io.length)
    end

    before do
      allow(fd_selector).to(
        receive(:charstrings_index).and_return(charstrings_index)
      )
    end

    it 'includes entries for all the glyphs in the font' do
      expect(fd_selector.count).to eq(entry_count)
    end

    it 'parses the entries correctly' do
      expect(fd_selector.to_a).to eq([1, 2, 3, 4, 5, 6])
    end

    it 'encodes correctly' do
      mapping = { 1 => 1, 3 => 3, 5 => 5 }
      expect(fd_selector.encode(mapping)).to eq("\x00\x02\x04\x06")
    end
  end

  context 'with a range-formatted selector' do
    let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

    it 'includes entries for all the glyphs in the font' do
      # the charstrings index doesn't contain an entry for the .notdef glyph
      expect(fd_selector.count).to(
        eq(font.cff.top_index[0].charstrings_index.count + 1)
      )
    end

    it 'parses the entries correctly' do
      fd_indices = fd_selector.to_a

      expect(fd_indices[0..10]).to eq(
        [5, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15]
      )

      expect(fd_indices[10..20]).to eq(
        [15, 15, 15, 15, 15, 15, 15, 17, 17, 17, 17]
      )

      expect(fd_indices[-10..-1]).to eq(
        [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
      )
    end

    it 'encodes correctly' do
      mapping = Hash[(0..15).map { |i| [i, i] }]
      result = fd_selector.encode(mapping)
      expect(result).to(
        #   fmt | count |  range 1  |  range 2  | n glyphs
        eq("\x03\x00\x02\x00\x00\x05\x00\x01\x0F\x00\x10")
      )
    end
  end
end
