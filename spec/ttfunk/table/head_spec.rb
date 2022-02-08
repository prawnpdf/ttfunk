# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/head'

RSpec.describe TTFunk::Table::Head do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }

  describe 'long_date_time helpers' do
    it 'parses the time correctly' do
      expect(described_class.from_long_date_time(font.header.created)).to eq(Time.new(2015, 6, 15, 5, 5, 32, 'UTC').utc)
    end

    it 'encodes the time correctly' do
      expect(described_class.to_long_date_time(Time.new(2015, 6, 15, 5, 5, 32, 'UTC'))).to eq(font.header.created)
    end

    example 'lossless roundrip' do
      time = 42

      expect(
        described_class.to_long_date_time(
          described_class.from_long_date_time(time)
        )
      ).to eq time
    end
  end
end
