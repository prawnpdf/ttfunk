require 'spec_helper'
require 'ttfunk/table/os2'
require 'ttfunk/subset'

RSpec.describe TTFunk::Table::OS2 do
  let(:bits_to_blocks) do
    described_class::UNICODE_BLOCKS.each_with_object({}) do |(range, bit), ret|
      ret[bit] ||= []
      ret[bit] << range
    end
  end

  # unicode char_range bits
  let(:greek) { 7 }          # Greek and Coptic
  let(:armenian) { 10 }      # Armenian
  let(:hebrew) { 11 }        # Hebrew
  let(:thai) { 24 }          # Thai
  let(:greek_ext) { 30 }     # Greek extended
  let(:curr_symbols) { 33 }  # currency symbols
  let(:shapes) { 45 }        # geometric shapes
  let(:ogham) { 78 }         # Ogham
  let(:old_italic) { 85 }    # Old Italic

  let(:char_range_field_indices) { 42...58 }
  let(:code_page_range_field_indices) { 78...86 }

  let(:font_path) { test_font('DejaVuSans') }
  let(:font) { TTFunk::File.open(font_path) }

  subject { font.os2 }

  let(:expected_fields) do
    {
      version: 1,
      ave_char_width: 1038,
      weight_class: 400,
      width_class: 5,
      type: 0,
      y_subscript_x_size: 1331,
      y_subscript_y_size: 1433,
      y_subscript_x_offset: 0,
      y_subscript_y_offset: 286,
      y_superscript_x_size: 1331,
      y_superscript_y_size: 1433,
      y_superscript_x_offset: 0,
      y_superscript_y_offset: 983,
      y_strikeout_size: 102,
      y_strikeout_position: 530,
      family_class: 0,
      panose: "\x02\v\x06\x03\x03\b\x04\x02\x02\x04",
      char_range: 3_138_825_546_350_813_869_068_267_263,
      vendor_id: 'PfEd',
      selection: 64,
      first_char_index: 32,
      last_char_index: 65_535,
      ascent: 1556,
      descent: -492,
      line_gap: 410,
      win_ascent: 1901,
      win_descent: 483,
      code_page_range: 16_140_619_591_129_760_255,

      # require os2 version 2 or above
      x_height: nil,
      cap_height: nil,
      default_char: nil,
      break_char: nil,
      max_context: nil
    }
  end

  let(:error_message) do
    <<-ERROR_MESSAGE.freeze
         field: %{field}
      expected: %{expected_value}
           got: %{actual_value}
    ERROR_MESSAGE
  end

  def build_error_message(field, expected_value, actual_value)
    strip_leading_spaces(
      format(
        error_message,
        field: field,
        expected_value: expected_value,
        actual_value: actual_value
      )
    )
  end

  it 'parses all fields correctly' do
    expected_fields.each do |field, expected_value|
      actual_value = subject.public_send(field)
      actual_value = actual_value.value if actual_value.respond_to?(:value)
      expect(actual_value).to(
        eq(expected_value),
        build_error_message(field, expected_value, actual_value)
      )
    end
  end

  describe '.encode' do
    let(:encoded) { subject.class.encode(subject, subset) }

    let(:code_page_range) do
      TTFunk::BitField.new(
        TTFunk::BinUtils.stitch_int(
          encoded[code_page_range_field_indices].unpack('N*'),
          bit_width: 32
        )
      )
    end

    let(:char_range) do
      TTFunk::BitField.new(
        TTFunk::BinUtils.stitch_int(
          encoded[char_range_field_indices].unpack('N*'), bit_width: 32
        )
      )
    end

    context 'with a unicode subset' do
      let(:subset) { TTFunk::Subset::Unicode.new(font) }
      let(:original_unicode_map) { font.cmap.unicode.first.code_map }

      it 'roundtrips correctly' do
        original_unicode_map.each_key { |char| subset.use(char) }
        reconstituted = described_class.new(
          TestFile.new(StringIO.new(encoded))
        )

        expected_fields.each do |field, expected_value|
          actual_value = reconstituted.public_send(field)

          # check these fields manually (they have been recalculated)
          next if %i[char_range code_page_range].include?(field)

          expect(actual_value).to(
            eq(expected_value),
            build_error_message(
              field, expected_value, actual_value
            )
          )
        end

        # since we're asking for a unicode subset, code_page_range should
        # be zero
        expect(reconstituted.code_page_range.value).to eq(0)

        # check several of the bits in char_range, which specifies unicode
        # blocks the font supports
        char_range_bits = [
          greek,
          armenian,
          hebrew,
          thai,
          greek_ext,
          curr_symbols,
          shapes,
          ogham,
          old_italic
        ]

        char_range_bits.each do |bit|
          expect(reconstituted.char_range.on?(bit)).to(
            eq(true), build_error_message(bit, true, false)
          )
        end
      end

      it 'ensures char_range only includes the blocks in the subset' do
        # Armenian, geometric shapes
        [armenian, shapes].each do |bit|
          bits_to_blocks[bit].each do |range|
            range.each { |code_point| subset.use(code_point) }
          end
        end

        expect(char_range.on?(greek)).to eq(false)
        expect(char_range.on?(armenian)).to eq(true)
        expect(char_range.on?(hebrew)).to eq(false)
        expect(char_range.on?(shapes)).to eq(true)
        expect(char_range.on?(old_italic)).to eq(false)
      end
    end

    context 'with a mac roman subset' do
      let(:subset) { TTFunk::Subset::MacRoman.new(font) }
      let(:mac_roman_code_page_bit) { 29 }

      before do
        mapping = TTFunk::Subset::CodePage.unicode_mapping_for(
          Encoding::MACROMAN
        )

        mapping.each_value { |code_point| subset.use(code_point) }
      end

      it 'does not set any char_range (unicode) bits' do
        expect(char_range.value).to eq(0)
      end

      it 'sets the correct code page bit' do
        expect(code_page_range.on?(mac_roman_code_page_bit)).to eq(true)
      end
    end

    context 'with a windows 1252 subset' do
      let(:subset) { TTFunk::Subset::Windows1252.new(font) }
      let(:windows_1252_code_page_bit) { 0 }

      before do
        mapping = TTFunk::Subset::CodePage.unicode_mapping_for(
          Encoding::CP1252
        )

        mapping.each_value { |code_point| subset.use(code_point) }
      end

      it 'does not set any char_range (unicode) bits' do
        expect(char_range.value).to eq(0)
      end

      it 'sets the correct code page bit' do
        expect(code_page_range.on?(windows_1252_code_page_bit)).to eq(true)
      end
    end
  end
end
