# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/encoded_string'

RSpec.describe TTFunk::EncodedString do
  subject(:encoded_string) { described_class.new }

  describe '#<<' do
    it 'writes the given string' do
      encoded_string << 'foo'
      expect(encoded_string.string).to eq('foo')
    end

    it 'adds the given placeholder' do
      encoded_string << 'abc'
      encoded_string << TTFunk::Placeholder.new(:foo)
      placeholder = encoded_string.placeholders[:foo]
      expect(placeholder.position).to eq(3)
    end

    it 'allows shoveling on other instances of EncodedString' do
      other =
        described_class.new do |str|
          str << 'abc'
          str << TTFunk::Placeholder.new(:foo, length: 3)
        end

      expect(other.placeholders[:foo].position).to eq(3)

      encoded_string << 'def'
      encoded_string << other

      # carries over the placeholder and adjusts its position
      expect(encoded_string.placeholders[:foo].position).to eq(6)
    end

    it 'does not allow adding two placeholders with the same name' do
      encoded_string << TTFunk::Placeholder.new(:foo)
      expect { encoded_string << TTFunk::Placeholder.new(:foo) }.to(
        raise_error(TTFunk::DuplicatePlaceholderError)
      )
    end

    it 'adds padding bytes when adding a placeholder' do
      encoded_string << 'abc'
      encoded_string << TTFunk::Placeholder.new(:foo, length: 3)
      expect(encoded_string.__send__(:io).string).to eq("abc\0\0\0")
    end
  end

  describe '#concat' do
    it 'adds all arguments' do
      encoded_string = described_class.new
      encoded_string.concat("\00", "\01", "\02", TTFunk::Placeholder.new(:foo))

      expect(encoded_string.__send__(:io).string).to eq("\00\01\02\00")
      expect(encoded_string.placeholders[:foo]).to_not be_nil
    end

    it 'returns self' do
      empty_encoded_string = described_class.new
      encoded_string = empty_encoded_string.concat("\00", "\01", "\02")

      expect(encoded_string.string).to eq("\00\01\02")
      expect(encoded_string).to equal(empty_encoded_string)
    end
  end

  describe '#length' do
    it 'retrieves the number of bytes written' do
      encoded_string << 'foo'
      expect(encoded_string.length).to eq(3)
    end
  end

  describe '#string' do
    it 'retrieves the encoded string value' do
      encoded_string << 'foo'
      expect(encoded_string.string).to eq('foo')
    end

    it "raises an error if any placeholders haven't been resolved" do
      encoded_string << 'foo'
      encoded_string << TTFunk::Placeholder.new(:name)
      expect { encoded_string.string }.to(
        raise_error(TTFunk::UnresolvedPlaceholderError)
      )
    end
  end

  describe '#bytes' do
    it 'retrieves the encoded string bytes' do
      encoded_string << 'foo'
      expect(encoded_string.bytes).to eq([0x66, 0x6f, 0x6f])
    end

    it "raises an error if any placeholders haven't been resolved" do
      encoded_string << 'foo'
      encoded_string << TTFunk::Placeholder.new(:name)
      expect { encoded_string.bytes }.to(
        raise_error(TTFunk::UnresolvedPlaceholderError)
      )
    end
  end

  describe '#resolve_placeholder' do
    it 'replaces the placeholder bytes' do
      encoded_string << '123'
      encoded_string << TTFunk::Placeholder.new(:name, length: 3)
      encoded_string << '456def'
      encoded_string.resolve_placeholder(:name, 'ghi')
      expect(encoded_string.string).to eq('123ghi456def')
    end
  end

  describe '#align!' do
    it 'byte-aligns the string by padding it' do
      encoded_string << 'abc'
      expect(encoded_string.align!.string).to eq("abc\0")
    end
  end
end
