# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/cff'

RSpec.describe TTFunk::Table::Cff::FontDict do
  let(:font) { TTFunk::File.open(font_path) }
  let(:font_dict) { font.cff.top_index[0].font_index[0] }
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }

  describe '#private_dict' do
    let(:private_dict) { font_dict.private_dict }

    # for more thorough testing, see the private dict spec
    it 'provides access to the private dict' do
      expect(private_dict).to be_a(TTFunk::Table::Cff::PrivateDict)
      expect(private_dict.default_width_x).to eq(1000)
    end
  end

  describe '#encode' do
    let(:top_dict) do
      instance_double(TTFunk::Table::Cff::TopDict, :top_dict, cff_offset: 0)
    end

    it 'produces an encoded dict that can be re-parsed successfully' do
      result = font_dict.encode
      dict_length = result.length
      private_dict_length = font_dict.private_dict.encode.length

      font_dict.finalize(result)
      io = StringIO.new(result.string)
      file = TestFile.new(io)
      new_dict = described_class.new(top_dict, file, 0, dict_length)

      expect(new_dict.to_h).to(
        eq(
          font_dict.to_h.merge(
            described_class::OPERATORS[:private] => [
              private_dict_length, dict_length,
            ],
          ),
        ),
      )

      expect(new_dict.private_dict.count).to eq(font_dict.private_dict.count)
    end
  end
end
