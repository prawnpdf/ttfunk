# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::TopDict do
  let(:font) { TTFunk::File.open(font_path) }
  let(:top_dict) { font.cff.top_index[0] }
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

  context 'with a CID-keyed font' do
    subject { top_dict.is_cid_font? }

    describe '#is_cid_font?' do
      it { is_expected.to be(true) }
    end
  end

  describe '#encode' do
    it 'produces an encoded dict that can be re-parsed successfully' do
      charmap = font.cmap.unicode.first.code_map.transform_values { |v| { old: v, new: v } }
      encoded = top_dict.encode
      top_dict_length = encoded.length
      top_dict_hash = top_dict.to_h
      placeholders = encoded.placeholders.dup
      top_dict.finalize(encoded, charmap)

      file = TestFile.new(StringIO.new(encoded.string))
      new_top_dict = described_class.new(file, 0, top_dict_length)
      new_top_dict_hash = new_top_dict.to_h

      # replace all the old offsets with the new ones so the dicts
      # (hopefully) match
      placeholders.each do |name, placeholder|
        start = placeholder.position + 1
        finish = placeholder.position + placeholder.length
        offset = encoded.string[start...finish].unpack1('N')
        operator = described_class::POINTER_OPERATORS[name]
        top_dict_hash[operator][-1] = offset
      end

      expect(new_top_dict_hash).to eq(top_dict_hash)
    end
  end

  context 'with a non CID-keyed font' do
    subject { top_dict.is_cid_font? }

    let(:font_path) { test_font('Exo-Regular', :otf) }

    describe '#is_cid_font?' do
      it { is_expected.to be(false) }
    end
  end
end
