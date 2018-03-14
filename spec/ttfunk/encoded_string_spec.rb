require 'spec_helper'
require 'ttfunk/encoded_string'

RSpec.describe TTFunk::EncodedString do
  subject { described_class.new }

  describe '#<<' do
    it 'writes the given string' do
      subject << 'foo'
      expect(subject.string).to eq('foo')
    end

    it 'adds the given placeholder' do
      subject << 'abc'
      subject << TTFunk::Placeholder.new(:foo)
      placeholder = subject.placeholders[:foo]
      expect(placeholder.position).to eq(3)
    end

    it 'allows shoveling on other instances of EncodedString' do
      other = described_class.new do |str|
        str << 'abc'
        str << TTFunk::Placeholder.new(:foo, length: 3)
      end

      expect(other.placeholders[:foo].position).to eq(3)

      subject << 'def'
      subject << other

      # carries over the placeholder and adjusts its position
      expect(subject.placeholders[:foo].position).to eq(6)
    end

    it 'does not allow adding two placeholders with the same name' do
      subject << TTFunk::Placeholder.new(:foo)
      expect { subject << TTFunk::Placeholder.new(:foo) }.to(
        raise_error(TTFunk::DuplicatePlaceholderError)
      )
    end

    it 'adds padding bytes when adding a placeholder' do
      subject << 'abc'
      subject << TTFunk::Placeholder.new(:foo, length: 3)
      expect(subject.send(:io).string).to eq("abc\0\0\0")
    end
  end

  describe '#length' do
    it 'retrieves the number of bytes written' do
      subject << 'foo'
      expect(subject.length).to eq(3)
    end
  end

  describe '#string' do
    it 'retrieves the encoded string value' do
      subject << 'foo'
      expect(subject.string).to eq('foo')
    end

    it "raises an error if any placeholders haven't been resolved" do
      subject << 'foo'
      subject << TTFunk::Placeholder.new(:name)
      expect { subject.string }.to(
        raise_error(TTFunk::UnresolvedPlaceholderError)
      )
    end
  end

  describe '#resolve_placeholder' do
    it 'replaces the placeholder bytes' do
      subject << '123'
      subject << TTFunk::Placeholder.new(:name, length: 3)
      subject << '456def'
      subject.resolve_placeholder(:name, 'ghi')
      expect(subject.string).to eq('123ghi456def')
    end
  end

  describe '#align!' do
    it 'byte-aligns the string by padding it' do
      subject << 'abc'
      expect(subject.align!.string).to eq("abc\0")
    end
  end
end
