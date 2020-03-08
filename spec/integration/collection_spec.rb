# frozen_string_literal: true

require 'spec_helper'

describe TTFunk::Collection do
  describe '.open' do
    it 'will not open non-TTC files' do
      expect { described_class.open test_font('DejaVuSans') }
        .to raise_error(ArgumentError)
    end

    it 'will open TTC files' do
      success = false

      described_class.open(test_font('DejaVuSans', :ttc)) do |_ttc|
        success = true
      end

      expect(success).to be true
    end

    it 'will open TTC files as IO' do
      success = false

      io = StringIO.new(File.read(test_font('DejaVuSans', :ttc)))
      described_class.open(io) do |_ttc|
        success = true
      end

      expect(success).to be true
    end

    it 'will report fonts in TTC' do
      described_class.open(test_font('DejaVuSans', :ttc)) do |ttc|
        expect(ttc.count).to eq 2
        expect(ttc[0].name.font_name.first).to eq 'DejaVu Sans'
        expect(ttc[1].name.font_name.first).to eq 'DejaVu Sans Bold'
      end
    end
  end
end
