# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/table/dsig'

RSpec.describe TTFunk::Table::Dsig do
  let(:font_path) { test_font('NotoSansCJKsc-Thin', :otf) }
  let(:font) { TTFunk::File.open(font_path) }
  let(:dsig_table) { font.digital_signature }

  describe '.encode' do
    let(:encoded) { described_class.encode(dsig_table) }
    let(:reconstituted) do
      described_class.new(TestFile.new(StringIO.new(encoded)))
    end

    it 'includes the same version information' do
      expect(reconstituted.version).to eq(dsig_table.version)
    end

    it 'zeroes out the flags' do
      expect(reconstituted.flags).to eq(0)
    end

    it 'removes all signature records' do
      expect(reconstituted.signatures).to be_empty
    end
  end
end
