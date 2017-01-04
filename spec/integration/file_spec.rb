require 'spec_helper'

describe TTFunk::File, '::open' do
  it 'opens file paths' do
    font = TTFunk::File.open test_font('DejaVuSans')
    expect(font.contents.read(4)).to eq("\x00\x00\x00\x01")
  end

  it 'opens IO Objects' do
    io = File.open test_font('DejaVuSans')
    font = TTFunk::File.open io
    expect(font.contents.read(4)).to eq("\x00\x00\x00\x01")
  end
end

describe TTFunk::File, '#ascent' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }

    it 'should extract the correct value' do
      expect(file.ascent).to eq(1556)
    end
  end
end

describe TTFunk::File, '#descent' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }

    it 'should extract the correct value' do
      expect(file.descent).to eq(-492)
    end
  end
end

describe TTFunk::File, '#line_gap' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }

    it 'should extract the correct value' do
      expect(file.line_gap).to eq(410)
    end
  end
end

describe TTFunk::File, '#bbox' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }

    it 'should extract the correct value' do
      expect(file.bbox).to eq([-2090, -850, 3442, 2389])
    end
  end
end

describe TTFunk::File, 'preferred_family_name' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }
    it 'should extract the correct value' do
      expect(file.name.preferred_family.first).to eq('DejaVu Sans')
    end
  end
end

describe TTFunk::File, '#cmap' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }

    it 'should extract cmap tables in descending order of format' do
      cmaps = file.cmap.unicode
      expect(cmaps.size).to eq(4)
      expect(cmaps.map(&:format)).to eq([12, 12, 4, 4])
    end

    it 'should lookup code in cmap format 12 table' do
      cmap_format12 = file.cmap.unicode.first
      expect(cmap_format12.format).to eq(12)
      expect(cmap_format12[32]).to eq(3)
    end
  end

  # M+ 1p is a CJK font that includes a cmap format 14 table we use a trimmed
  # down version of the font generated with fontforge for testing purposes
  context 'with M+ 1p' do
    let!(:file) { TTFunk::File.open(test_font('Mplus1p')) }

    # this test verifies that the cmap format 14 table is ignored
    it 'should extract cmap tables in descending order of format' do
      cmaps = file.cmap.unicode
      expect(cmaps.size).to eq(2)
      expect(cmaps.map(&:format)).to eq([4, 4])
    end

    it 'should lookup code in cmap format 4 table' do
      cmap_format4 = file.cmap.unicode.first
      expect(cmap_format4.format).to eq(4)
      expect(cmap_format4[32]).to eq(4)
    end
  end
end

describe TTFunk::File, '#directory_info' do
  context 'with DejaVuSans' do
    let!(:file) { TTFunk::File.open(test_font('DejaVuSans')) }

    it 'should extract the correct value'
  end
end

describe TTFunk::File, '#sbix' do
  context 'with ColorTestSbix' do
    # Thank you http://typophile.com/node/103268 for ColorTestSbix.ttf
    let!(:file) { TTFunk::File.open(test_font('ColorTestSbix')) }

    it 'should should extract headers' do
      expect(file.sbix.version).to eq(1)
      expect(file.sbix.flags).to eq(1)
      expect(file.sbix.num_strikes).to eq(1)
    end

    it 'should extract bitmap data given a glyph id and strike index' do
      bitmap = file.sbix.bitmap_data_for(4, 0)
      expect(bitmap.x).to eq(0)
      expect(bitmap.y).to eq(0)
      expect(bitmap.type).to eq('png')
      expect(bitmap.data.read).to match(/IHDR.*ImageReady.*IEND/m)
      expect(bitmap.ppem).to eq(150)
      expect(bitmap.resolution).to eq(72)
    end

    it 'should extract an array of all bitmap data given a glyph id' do
      all_bitmaps = file.sbix.all_bitmap_data_for(4)
      expect(all_bitmaps.size).to eq(1)
      expect(all_bitmaps[0].ppem).to eq(150)
    end
  end
end
