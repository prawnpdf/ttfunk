# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }
  let(:name_index) { font.cff.name_index }

  it 'contains the name of the font' do
    expect(name_index.to_a).to eq(['NotoSansCJKsc-Thin'])
  end

  describe '#encode' do
    it 'encodes the index correctly' do
      encoded = name_index.encode
      reconstituted = described_class::Index.new(
        TestFile.new(StringIO.new(encoded.string)), 0
      )

      expect(reconstituted.to_a).to eq(['NotoSansCJKsc-Thin'])
    end
  end
end
