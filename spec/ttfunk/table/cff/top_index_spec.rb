# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::TopIndex do
  let(:font) { TTFunk::File.open(font_path) }
  let(:top_index) { font.cff.top_index }

  shared_examples 'a CFF-based font' do
    it 'provides access to top dicts' do
      expect(top_index[0]).to be_a(TTFunk::Table::Cff::TopDict)
    end

    it 'always contains a single top dict' do
      expect(top_index.count).to eq(1)
    end
  end

  context 'with the noto font' do
    let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

    it_behaves_like 'a CFF-based font'
  end

  context 'with the exo font' do
    let(:font_path) { test_font('Exo-Regular', :otf) }

    it_behaves_like 'a CFF-based font'
  end

  context 'with the comic jens font' do
    let(:font_path) { test_font('ComicJens-Regular', :otf) }

    it_behaves_like 'a CFF-based font'
  end
end
