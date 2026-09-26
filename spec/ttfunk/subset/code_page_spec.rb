# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/subset'

RSpec.describe TTFunk::Subset::CodePage do
  let(:font) { TTFunk::File.open(test_font('DejaVuSans')) }
  let(:subset) { TTFunk::Subset.for(font, :mac_roman) }

  describe '#from_unicode' do
    it 'maps a character the code page holds' do
      expect(subset.from_unicode('é'.ord)).to eq(142)
    end

    it 'answers nil for a character the code page does not hold' do
      expect(subset.from_unicode('Ж'.ord)).to be_nil
    end

    it 'gives the same answers when asked again' do
      chars = %w[A é Ж]
      first = chars.map { |char| subset.from_unicode(char.ord) }
      second = chars.map { |char| subset.from_unicode(char.ord) }

      expect(second).to eq(first)
    end

    it 'converts a missing character only once' do
      raised = 0
      trace =
        TracePoint.new(:raise) do |tp|
          raised += 1 if tp.raised_exception.is_a?(Encoding::UndefinedConversionError)
        end

      trace.enable { 3.times { subset.from_unicode('Ж'.ord) } }

      expect(raised).to eq(1)
    end
  end
end
