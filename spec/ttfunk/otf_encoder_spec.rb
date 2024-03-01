# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/otf_encoder'
require 'ttfunk/subset'

RSpec.describe TTFunk::OTFEncoder do
  let(:original_font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:original) { TTFunk::File.open(original_font_path) }

  let(:subset) do
    TTFunk::Subset::Unicode.new(original).tap do |subset|
      # ASCII lowercase
      (97..122).each { |char| subset.use(char) }
    end
  end

  let(:encoder_options) { {} }
  let(:encoder) { described_class.new(original, subset, encoder_options) }

  describe '#encode' do
    subject { encoder.encode }

    let(:new_font) { TTFunk::File.open(StringIO.new(subject)) }

    it 'includes the CFF, VORG, and DSIG tables' do
      expect(new_font.directory.tables).to include('CFF ')
      expect(new_font.directory.tables).to include('VORG')
      expect(new_font.directory.tables).to include('DSIG')
    end

    it 'lists tables in optimal order' do
      tables = described_class::OPTIMAL_TABLE_ORDER &
        new_font.directory.tables.keys

      tables.each_cons(2) do |first_table, second_table|
        expect(new_font.directory.tables[first_table][:offset]).to be < new_font.directory.tables[second_table][:offset]
      end
    end
  end
end
