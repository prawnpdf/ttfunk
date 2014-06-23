# coding: utf-8

require "spec_helper"

describe TTFunk::File, "::open" do
  it "opens file paths" do
    font = TTFunk::File.open test_font("DejaVuSans")
    font.contents.read(4).should == "\x00\x00\x00\x01"
  end

  it "opens IO Objects" do
    io = File.open test_font("DejaVuSans")
    font = TTFunk::File.open io
    font.contents.read(4).should == "\x00\x00\x00\x01"
  end
end

describe TTFunk::File, "#ascent" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      file.ascent.should == 1556
    end
  end
end

describe TTFunk::File, "#descent" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      file.descent.should == -492
    end
  end
end

describe TTFunk::File, "#line_gap" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      file.line_gap.should == 410
    end
  end
end

describe TTFunk::File, "#bbox" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value" do
      file.bbox.should == [-2090, -850, 3442, 2389]
    end
  end
end

describe TTFunk::File, "preferred_family_name" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}
    it "should extract the correct value" do
      file.name.preferred_family.first.should == 'DejaVu Sans'
    end
  end
end

describe TTFunk::File, "#directory_info" do

  context "with DejaVuSans" do
    let!(:file) { TTFunk::File.open(test_font("DejaVuSans"))}

    it "should extract the correct value"
  end
end
