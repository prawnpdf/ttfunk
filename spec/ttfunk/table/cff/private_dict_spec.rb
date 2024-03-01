# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::PrivateDict do
  let(:font) { TTFunk::File.open(font_path) }
  let(:private_dict) { font.cff.top_index[0].font_index[0].private_dict }
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

  describe '#default_width_x' do
    it 'identifies the correct default x width' do
      expect(private_dict.default_width_x).to eq(1000)
    end
  end

  describe '#nominal_width_x' do
    it 'identifies the correct nominal x width' do
      # this is the default if no nominal width is specified
      expect(private_dict.nominal_width_x).to eq(0)
    end
  end

  describe '#subr_index' do
    let(:subr_index) { private_dict.subr_index }

    it 'fetches the subroutine index' do
      expect(subr_index).to be_a(TTFunk::Table::Cff::SubrIndex)
    end

    it 'parses subroutines correctly' do
      # Subroutines provide shared chunks of instructions that can be used
      # when constructing charstrings. In other words, these seemingly
      # random bytes mean something specific to the charstrings code. See
      # the subr index tests for more.
      expect(subr_index[2].bytes).to eq [127, 171, 119, 159, 248, 122, 171, 18, 11]
    end
  end

  describe '#encode' do
    it 'produces an encoded dict that can be re-parsed successfully' do
      result = private_dict.encode
      dict_length = result.length

      private_dict.finalize(result)
      io = StringIO.new(result.string)
      file = TestFile.new(io)
      new_dict = described_class.new(file, 0, dict_length)

      expect(new_dict.to_h).to(
        eq(
          private_dict.to_h.merge(
            described_class::OPERATORS[:subrs] => [dict_length],
          ),
        ),
      )

      expect(new_dict.subr_index.items_count).to eq(private_dict.subr_index.items_count)
    end
  end
end
