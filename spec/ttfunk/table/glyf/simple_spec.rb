# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk'

RSpec.describe TTFunk::Table::Glyf::Simple do
  let(:font) { TTFunk::File.open(test_font('DejaVuSans')) }
  let(:glyph_id) { font.cmap.unicode.first[codepoint] }
  let(:glyph) { font.glyph_outlines.for(glyph_id) }

  describe '#contours' do
    context 'with a straight-line glyph' do
      let(:codepoint) { 'A'.ord }

      it 'returns one array of points per contour' do
        expect(glyph.contours.length).to eq(glyph.number_of_contours)
      end

      it 'decodes every point of the glyph' do
        expect(glyph.contours.sum(&:length)).to eq(glyph.end_point_of_last_contour)
      end

      it 'decodes coordinates spanning exactly the glyph bounding box' do
        points = glyph.contours.flatten

        expect(points.map(&:x).minmax).to eq([glyph.x_min, glyph.x_max])
        expect(points.map(&:y).minmax).to eq([glyph.y_min, glyph.y_max])
      end

      it 'memoizes the decoded contours' do
        expect(glyph.contours).to equal(glyph.contours)
      end
    end

    context 'with a curved glyph' do
      let(:codepoint) { 'o'.ord }

      it 'marks quadratic control points as off-curve' do
        on_curve_values = glyph.contours.flatten.map(&:on_curve).uniq

        expect(on_curve_values).to contain_exactly(true, false)
      end

      it 'decodes coordinates spanning exactly the glyph bounding box' do
        points = glyph.contours.flatten

        expect(points.map(&:x).minmax).to eq([glyph.x_min, glyph.x_max])
        expect(points.map(&:y).minmax).to eq([glyph.y_min, glyph.y_max])
      end
    end
  end
end
