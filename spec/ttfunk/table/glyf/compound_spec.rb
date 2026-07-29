# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk'

RSpec.describe TTFunk::Table::Glyf::Compound do
  describe '#components' do
    context 'with a composite glyph from a real font' do
      let(:font) { TTFunk::File.open(test_font('DejaVuSans')) }
      let(:glyph_id) { font.cmap.unicode.first[0xE9] } # e acute
      let(:glyph) { font.glyph_outlines.for(glyph_id) }

      it 'parses one record per referenced glyph, in order' do
        expect(glyph.components.map(&:glyph_index)).to eq(glyph.glyph_ids)
      end

      it 'parses offset-placed components with signed x/y offsets' do
        expect(glyph.components).to all(
          satisfy { |component| component.flags.allbits?(described_class::ARGS_ARE_XY_VALUES) },
        )
      end

      it 'memoizes the parsed components' do
        expect(glyph.components).to equal(glyph.components)
      end
    end

    context 'with a hand-built scaled component' do
      let(:raw) {
        header = [-1, 0, 0, 100, 100].pack('s>*')
        flags =
          described_class::ARG_1_AND_2_ARE_WORDS |
          described_class::ARGS_ARE_XY_VALUES |
          described_class::WE_HAVE_A_SCALE
        header + [flags, 7].pack('n*') + [10, -20].pack('s>*') + [0x2000].pack('n')
      }
      let(:component) { described_class.new(0, raw).components.first }

      it 'parses the component record' do
        expect(component.to_h).to include(glyph_index: 7, arg1: 10, arg2: -20)
      end

      it 'parses the F2Dot14 scale' do
        expect(component.transform).to eq([0.5])
      end
    end

    context 'with a hand-built point-matching component' do
      let(:raw) {
        header = [-1, 0, 0, 100, 100].pack('s>*')
        header + [0x0000, 7].pack('n*') + [200, 3].pack('C*')
      }
      let(:component) { described_class.new(0, raw).components.first }

      it 'keeps point numbers unsigned' do
        expect(component.to_h).to include(arg1: 200, arg2: 3)
      end
    end
  end
end
