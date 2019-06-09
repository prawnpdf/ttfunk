# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/vorg'

RSpec.describe TTFunk::Table::Vorg do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }
  let(:cmap) { font.cmap.unicode.first }
  let(:vorg_table) { font.vertical_origins }
  let(:origins) { vorg_table.origins }

  describe '#origins' do
    it 'includes origins for certain chars traditionally written vertically' do
      code_points = %w[〱 ０ １ ２ ３ ４ ５ ６ ７ ８ ９].map do |c|
        c.unpack1('U*')
      end

      glyph_ids = code_points.map { |cp| cmap[cp] }
      glyph_ids.each { |glyph_id| expect(origins).to include(glyph_id) }
    end
  end

  describe '#for' do
    it 'finds the vertical origin when explicitly available' do
      glyph_id = cmap['〱'.unpack1('U*')]
      expect(vorg_table.origins).to include(glyph_id)
      expect(vorg_table.for(glyph_id)).to_not(
        eq(vorg_table.default_vert_origin_y)
      )
    end

    it 'falls back to the default vertical origin' do
      glyph_id = cmap['ろ'.unpack1('U*')]
      expect(vorg_table.origins).to_not include(glyph_id)
      expect(vorg_table.for(glyph_id)).to(
        eq(vorg_table.default_vert_origin_y)
      )
    end
  end

  describe '.encode' do
    let(:encoded) { described_class.encode(vorg_table) }
    let(:reconstituted) do
      described_class.new(TestFile.new(StringIO.new(encoded)))
    end

    it 'includes all the same vertical origins' do
      expect(reconstituted.origins.size).to eq(origins.size)

      origins.each do |glyph_id, origin|
        expect(reconstituted.origins[glyph_id]).to eq(origin)
      end
    end

    it 'includes the same version information' do
      expect(reconstituted.major_version).to eq(vorg_table.major_version)
      expect(reconstituted.minor_version).to eq(vorg_table.minor_version)
    end

    it 'includes the same default vertical origin' do
      expect(reconstituted.default_vert_origin_y).to(
        eq(vorg_table.default_vert_origin_y)
      )
    end
  end
end
