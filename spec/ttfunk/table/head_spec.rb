# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/head'

RSpec.describe TTFunk::Table::Head do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }

  describe '#created' do
    it 'parses the field correctly' do
      expect(font.header.created).to eq(Time.new(2015, 6, 15, 5, 5, 32, 0).utc)
    end
  end

  describe '#modified' do
    it 'parses the field correctly' do
      expect(font.header.modified).to eq(Time.new(2015, 6, 15, 5, 5, 32, 0).utc)
    end
  end
end
