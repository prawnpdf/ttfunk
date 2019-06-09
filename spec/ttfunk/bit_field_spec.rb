# frozen_string_literal: true

require 'spec_helper'
require 'ttfunk/bit_field'

RSpec.describe TTFunk::BitField do
  subject(:bit_field) { described_class.new(value) }

  let(:value) { 0b10100110 }

  describe '#on?' do
    it 'determines that the correct bits are on' do
      expect(bit_field.on?(0)).to eq(false)
      expect(bit_field.on?(1)).to eq(true)
      expect(bit_field.on?(2)).to eq(true)
      expect(bit_field.on?(3)).to eq(false)
      expect(bit_field.on?(4)).to eq(false)
      expect(bit_field.on?(5)).to eq(true)
      expect(bit_field.on?(6)).to eq(false)
      expect(bit_field.on?(7)).to eq(true)
    end
  end

  describe '#off?' do
    it 'determines that the correct bits are off' do
      expect(bit_field.off?(0)).to eq(true)
      expect(bit_field.off?(1)).to eq(false)
      expect(bit_field.off?(2)).to eq(false)
      expect(bit_field.off?(3)).to eq(true)
      expect(bit_field.off?(4)).to eq(true)
      expect(bit_field.off?(5)).to eq(false)
      expect(bit_field.off?(6)).to eq(true)
      expect(bit_field.off?(7)).to eq(false)
    end
  end

  describe '#on' do
    it 'turns the given bit on' do
      expect { bit_field.on(3) }.to(
        change { bit_field.on?(3) }.from(false).to(true)
      )
    end

    it 'updates the value' do
      expect { bit_field.on(0) }.to(
        change(bit_field, :value).from(0b10100110).to(0b10100111)
      )

      expect { bit_field.on(3) }.to(
        change(bit_field, :value).from(0b10100111).to(0b10101111)
      )
    end

    it 'does not update the value if no bits were flipped' do
      expect { bit_field.on(1) }.to_not(change(bit_field, :value))
    end
  end

  describe '#off' do
    it 'turns the given bit off' do
      expect { bit_field.off(5) }.to(
        change { bit_field.off?(5) }.from(false).to(true)
      )
    end

    it 'updates the value' do
      expect { bit_field.off(1) }.to(
        change(bit_field, :value).from(0b10100110).to(0b10100100)
      )

      expect { bit_field.off(5) }.to(
        change(bit_field, :value).from(0b10100100).to(0b10000100)
      )
    end

    it 'does not update the value if no bits were flipped' do
      expect { bit_field.off(3) }.to_not(change(bit_field, :value))
    end
  end
end
