# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/ttf_encoder'
require 'ttfunk/subset'

RSpec.describe TTFunk::TTFEncoder do
  let(:original_font_path) { test_font('DejaVuSans') }
  let(:original) { TTFunk::File.open(original_font_path) }

  let(:encoder_options) { {} }
  let(:encoder) do
    subset =
      TTFunk::Subset::Unicode.new(original).tap do |sub_set|
        # ASCII lowercase
        (97..122).each { |char| sub_set.use(char) }
      end

    described_class.new(original, subset, encoder_options)
  end

  describe '#encode' do
    subject(:encoded_ttf) { encoder.encode }

    let(:new_font) { TTFunk::File.open(StringIO.new(encoded_ttf)) }

    it 'includes all supported tables' do
      expect(new_font.directory.tables).to include('cmap')
      expect(new_font.directory.tables).to include('glyf')
      expect(new_font.directory.tables).to include('loca')
      expect(new_font.directory.tables).to include('hmtx')
      expect(new_font.directory.tables).to include('hhea')
      expect(new_font.directory.tables).to include('maxp')
      expect(new_font.directory.tables).to include('OS/2')
      expect(new_font.directory.tables).to include('post')
      expect(new_font.directory.tables).to include('name')
      expect(new_font.directory.tables).to include('head')
      expect(new_font.directory.tables).to include('prep')
      expect(new_font.directory.tables).to include('fpgm')
      expect(new_font.directory.tables).to include('cvt ')
    end

    context 'when asked to encode the kern table' do
      let(:encoder_options) { { kerning: true } }

      it 'includes the kern table' do
        expect(new_font.directory.tables).to include('kern')
      end
    end

    it 'lists tables in optimal order' do
      tables = described_class::OPTIMAL_TABLE_ORDER &
        new_font.directory.tables.keys

      tables.each_cons(2) do |first_table, second_table|
        expect(new_font.directory.tables[first_table][:offset]).to(
          be < new_font.directory.tables[second_table][:offset]
        )
      end
    end

    it 'is checksummed correctly' do
      head_offset = new_font.directory.tables['head'][:offset]
      checksum = encoded_ttf[head_offset + 8, 4].unpack1('N')

      # verified via the Font-Validator tool at:
      # https://github.com/HinTak/Font-Validator
      expect(checksum).to eq(0xEEAE9DCF)
    end
  end
end
