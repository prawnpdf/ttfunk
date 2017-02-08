# coding: utf-8

require "spec_helper"

describe TTFunk::Collection, "::open" do
  it "will not open non-TTC files" do
    expect { TTFunk::Collection.open test_font("DejaVuSans") }
      .to raise_error(ArgumentError)
  end

  it "will open TTC files" do
    success = false

    TTFunk::Collection.open(test_font("DejaVuSans", :ttc)) do |_ttc|
      success = true
    end

    expect(success).to be true
  end

  it "will report fonts in TTC" do
    TTFunk::Collection.open(test_font("DejaVuSans", :ttc)) do |ttc|
      expect(ttc.count).to eq 2
      expect(ttc[0].name.font_name.first).to eq "DejaVu Sans"
      expect(ttc[1].name.font_name.first).to eq "DejaVu Sans Bold"
    end
  end
end
