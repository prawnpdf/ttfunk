# frozen_string_literal: true

require 'spec_helper'
require 'stringio'
require 'ttfunk/subset'

describe TTFunk do
  describe 'subsetting' do
    let(:space_char) { TTFunk::Subset::Unicode::SPACE_CHAR }

    it 'consistently names font for same subsets' do
      font = TTFunk::File.open test_font('DejaVuSans')

      subset1 = TTFunk::Subset.for(font, :unicode)
      subset1.use(97)
      name1 = TTFunk::File.new(subset1.encode).name.strings[6]

      subset2 = TTFunk::Subset.for(font, :unicode)
      subset2.use(97)
      name2 = TTFunk::File.new(subset2.encode).name.strings[6]

      expect(name1).to eq name2
    end

    it 'can reconstruct an entire font' do
      font = TTFunk::File.open test_font('DejaVuSans')
      subset = TTFunk::Subset.for(font, :unicode)

      font.cmap.unicode.first.code_map.each do |code_point, _gid|
        subset.use(code_point)
      end

      expect { subset.encode }.to_not raise_error
    end

    it 'always includes the space glyph' do
      font = TTFunk::File.open test_font('DejaVuSans')
      subset = TTFunk::Subset.for(font, :unicode)
      new_font = TTFunk::File.new(subset.encode)

      # space should be GID 1 since it's the only glyph in the font
      # (0 is always .notdef)
      expect(new_font.cmap.unicode.first[space_char]).to eq(1)
    end

    it "explodes if the space glyph isn't included" do
      font = TTFunk::File.open test_font('DejaVuSans')
      subset = TTFunk::Subset.for(font, :unicode)
      subset.instance_variable_get(:@subset).delete(space_char)
      expect { subset.encode }.to raise_error(/Space glyph .* must be included/)
    end

    it 'changes font names for different subsets' do
      font = TTFunk::File.open test_font('DejaVuSans')

      subset1 = TTFunk::Subset.for(font, :unicode)
      subset1.use(97)
      name1 = TTFunk::File.new(subset1.encode).name.strings[6]

      subset2 = TTFunk::Subset.for(font, :unicode)
      subset2.use(97)
      subset2.use(98)
      name2 = TTFunk::File.new(subset2.encode).name.strings[6]

      expect(name1).to_not eq name2
    end

    it 'calculates checksum correctly for empty table data' do
      font = TTFunk::File.open test_font('Mplus1p')
      subset1 = TTFunk::Subset.for(font, :unicode)
      expect { subset1.encode }.to_not raise_error
    end

    it 'generates font directory with tables in ascending order' do
      font = TTFunk::File.open test_font('DejaVuSans')

      subset = TTFunk::Subset.for(font, :unicode)
      subset.use(97)

      directory = TTFunk::File.new(subset.encode).directory
      table_tags = directory.tables.keys

      expect(table_tags.sort).to eq(table_tags)
      expect(table_tags.first).to be < table_tags.last
    end

    it 'calculates search_range, entry_selector & range_shift values' do
      font = TTFunk::File.open test_font('DejaVuSans')

      subset = TTFunk::Subset.for(font, :unicode)
      subset.use(97)
      subset_io = StringIO.new(subset.encode)

      scaler_type, table_count = subset_io.read(6).unpack('Nn')
      search_range, entry_selector, range_shift =
        subset_io.read(6).unpack('nnn')

      # Subset fonts include 14 tables by default.
      expected_table_count = 14
      # Smallest power of two less than number of tables, times 16.
      expected_search_range = 8 * 16
      # Log2 of max power of two smaller than number of tables.
      expected_entry_selector = 3
      # Range shift is defined as 16*table_count - search_range.
      expected_range_shift = 16 * expected_table_count - expected_search_range

      expect(scaler_type).to eq(font.directory.scaler_type)
      expect(table_count).to eq(expected_table_count)
      expect(search_range).to eq(expected_search_range)
      expect(entry_selector).to eq(expected_entry_selector)
      expect(range_shift).to eq(expected_range_shift)
    end

    it 'knows which characters it includes' do
      font = TTFunk::File.open test_font('DejaVuSans')
      unicode = TTFunk::Subset.for(font, :unicode)
      unicode_8bit = TTFunk::Subset.for(font, :unicode_8bit)
      mac_roman = TTFunk::Subset.for(font, :mac_roman)
      windows1252 = TTFunk::Subset.for(font, :windows_1252)

      [unicode, unicode_8bit, mac_roman, windows1252].each do |subset|
        expect(subset).to_not be_includes(97)
        subset.use(97)
        expect(subset).to be_includes(97)
      end
    end

    it 'maps final code 0xFFFF to glyph 0 in generated type 4 cmap' do
      font = TTFunk::File.open test_font('DejaVuSans')

      subset = TTFunk::Subset.for(font, :unicode)
      subset.use(97)
      cmap = TTFunk::File.new(subset.encode).cmap

      # Unicode subsets only contain a single format 4 cmap subtable.
      expect(cmap.tables.size).to eq(1)
      format04 = cmap.tables.first
      expect(format04.format).to eq(4)
      expect(format04.code_map[0xFFFF]).to eq(0)
    end

    it 'sorts records in the name table correctly' do
      font = TTFunk::File.open test_font('DejaVuSans')

      subset = TTFunk::Subset.for(font, :unicode)
      subset.use(97)
      name = TTFunk::File.new(subset.encode).name

      records = []
      name.entries.each do |entry|
        records << [
          entry[:platform_id],
          entry[:encoding_id],
          entry[:language_id],
          entry[:name_id]
        ]
      end

      expect(records).to eq(records.sort)
    end
  end
end
