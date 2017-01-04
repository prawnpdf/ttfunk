require 'spec_helper'
require 'ttfunk/subset'

describe 'subsetting' do
  it 'consistently names font for same subsets' do
    font = TTFunk::File.open test_font('DejaVuSans')

    subset1 = TTFunk::Subset.for(font, :unicode)
    subset1.use(97)
    name1 = TTFunk::File.new(subset1.encode).name.strings[6]

    subset2 = TTFunk::Subset.for(font, :unicode)
    subset2.use(97)
    name2 = TTFunk::File.new(subset2.encode).name.strings[6]

    expect(name1).to eq name2
  end

  it 'changes font names for different subsets' do
    font = TTFunk::File.open test_font('DejaVuSans')

    subset1 = TTFunk::Subset.for(font, :unicode)
    subset1.use(97)
    name1 = TTFunk::File.new(subset1.encode).name.strings[6]

    subset2 = TTFunk::Subset.for(font, :unicode)
    subset2.use(97)
    subset2.use(98)
    name2 = TTFunk::File.new(subset2.encode).name.strings[6]

    expect(name1).to_not eq name2
  end
end
