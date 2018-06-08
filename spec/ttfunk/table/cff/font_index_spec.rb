require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::FontIndex do
  let(:font) { TTFunk::File.open(font_path) }
  let(:font_index) { font.cff.top_index[0].font_index }
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

  it 'provides access to font dicts by index' do
    expect(font_index.count).to eq(19)
    expect(font_index[0]).to be_a(TTFunk::Table::Cff::FontDict)
  end
end
