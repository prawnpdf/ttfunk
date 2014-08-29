# coding: utf-8

require "spec_helper"

describe TTFunk::File, "::open" do
  it "opens file paths" do
    font = TTFunk::File.open test_font("DejaVuSans")
    expect(font.contents.read(4)).to eq("\x00\x00\x00\x01")
  end

  it "opens IO Objects" do
    io = File.open test_font("DejaVuSans")
    font = TTFunk::File.open io
    expect(font.contents.read(4)).to eq("\x00\x00\x00\x01")
  end
end

describe TTFunk::File, "#ascent" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      expect(file.ascent).to eq(1556)
    end
  end
end

describe TTFunk::File, "#descent" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      expect(file.descent).to eq(-492)
    end
  end
end

describe TTFunk::File, "#line_gap" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      expect(file.line_gap).to eq(410)
    end
  end
end

describe TTFunk::File, "#bbox" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      expect(file.bbox).to eq([-2090, -850, 3442, 2389])
    end
  end
end

describe TTFunk::File, "preferred_family_name" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}
    it "should extract the correct value" do
      expect(file.name.preferred_family.first).to eq('DejaVu Sans')
    end
  end
end

describe TTFunk::File, "#cmap" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract cmap tables in descending order of format" do
      cmaps = file.cmap.unicode
      expect(cmaps.size).to eq(4)
      expect(cmaps.map(&:format)).to eq([12, 12, 4, 4])
    end

    it "should lookup code in cmap format 12 table" do
      cmap_format_12 = file.cmap.unicode.first
      expect(cmap_format_12.format).to eq(12)
      expect(cmap_format_12[32]).to eq(3)
    end
  end

  # M+ 1p is a CJK font that includes a cmap format 14 table
  # we use a trimmed down version of the font generated with fontforge for testing purposes
  context "with M+ 1p" do
    let!(:file) { TTFunk::File.open(test_font("Mplus1p"))}

    # this test verifies that the cmap format 14 table is ignored
    it "should extract cmap tables in descending order of format" do
      cmaps = file.cmap.unicode
      expect(cmaps.size).to eq(2)
      expect(cmaps.map(&:format)).to eq([4, 4])
    end

    it "should lookup code in cmap format 4 table" do
      cmap_format_4 = file.cmap.unicode.first
      expect(cmap_format_4.format).to eq(4)
      expect(cmap_format_4[32]).to eq(4)
    end
  end
end

describe TTFunk::File, "#directory_info" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value"
  end
end
