# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::Header do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }
  let(:header) { font.cff.header }

  it 'parses the major and minor versions correctly' do
    # i.e. CFF version 1.0
    expect(header.major).to eq(1)
    expect(header.minor).to eq(0)
  end

  it 'parses the header size correctly' do
    expect(header.header_size).to eq(4)
  end

  it 'parses the absolute offset size correctly' do
    # absolute offsets in the CFF data are no more than 3 bytes wide
    expect(header.absolute_offset_size).to eq(3)
  end

  describe '#encode' do
    it 'encodes the table correctly' do
      expect(header.encode).to eq([1, 0, 4, 3].pack('C*'))
    end
  end
end
