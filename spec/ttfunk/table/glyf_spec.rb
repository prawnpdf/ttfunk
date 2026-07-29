# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk'

RSpec.describe TTFunk::Table::Glyf do
  let(:font) { TTFunk::File.open(test_font('DejaVuSans')) }
  let(:table) { font.glyph_outlines }

  def glyph_id(codepoint)
    font.cmap.unicode.first[codepoint]
  end

  describe '#contours_for' do
    it 'returns the contours of a simple glyph directly' do
      expect(table.contours_for(glyph_id('A'.ord)))
        .to eq(table.for(glyph_id('A'.ord)).contours)
    end

    it 'returns no contours for a blank glyph' do
      expect(table.contours_for(glyph_id(' '.ord))).to be_empty
    end

    it 'resolves a composite into the contours of all its components' do
      component_contours =
        table.for(glyph_id(0xE9)).glyph_ids.sum { |id| table.contours_for(id).length }

      expect(table.contours_for(glyph_id(0xE9)).length).to eq(component_contours)
    end

    it 'translates component points by the component offsets' do
      accent = table.for(glyph_id(0xE9)).components.last
      translated =
        table.contours_for(accent.glyph_index).map { |contour|
          contour.map { |point| [point.x + accent.arg1, point.y + accent.arg2] }
        }
      resolved =
        table.contours_for(glyph_id(0xE9)).last(translated.length).map { |contour|
          contour.map { |point| [point.x, point.y] }
        }

      expect(resolved).to eq(translated)
    end

    it 'preserves on-curve information through composite resolution' do
      accent = table.for(glyph_id(0xE9)).components.last
      original = table.contours_for(accent.glyph_index).map { |contour| contour.map(&:on_curve) }
      resolved =
        table.contours_for(glyph_id(0xE9)).last(original.length).map { |contour|
          contour.map(&:on_curve)
        }

      expect(resolved).to eq(original)
    end
  end
end
