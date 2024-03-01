# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::SubrIndex do
  let(:font) { TTFunk::File.open(font_path) }
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font_index) { font.cff.top_index[0].font_index }

  it 'parses subroutines correctly' do
    expect(font_index[1].private_dict.subr_index[3].bytes).to eq [39, 10, 108, 116, 37, 10, 11]

    expect(font_index[15].private_dict.subr_index[6].bytes).to eq [174, 3, 34, 10, 11]

    expect(font_index[18].private_dict.subr_index[50].bytes).to eq [179, 172, 173, 179, 180, 172, 105, 99, 11]
  end

  context 'with an index with few subroutines' do
    let(:subr_index) { font_index[0].private_dict.subr_index }

    describe '#bias' do
      subject { subr_index.bias }

      it { is_expected.to eq(107) }
    end
  end

  context 'with an index with a considerable number of subroutines' do
    let(:subr_index) { font_index[13].private_dict.subr_index }

    describe '#bias' do
      subject { subr_index.bias }

      it { is_expected.to eq(1131) }
    end
  end
end
