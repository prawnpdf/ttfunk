require 'rubygems'
require 'ttfunk'
require 'valuable'
# Everything you never wanted to know about glyphs:
# http://chanae.walon.org/pub/ttf/ttf_glyphs.htm

# this code is a substantial reworking of:
# https://github.com/prawnpdf/ttfunk/blob/master/examples/metrics.rb

class Font
  attr_reader :file

  def initialize(path_to_file)
    @file = TTFunk::File.open(path_to_file)
  end
  
  def width_of( string )
    string.split('').map{|char| character_width( char )}.inject{|sum, x| sum + x}
  end

  def character_width( character )
    width_in_units = ( horizontal_metrics.for( glyph_id( character )).advance_width )
    width_in_units.to_f / units_per_em
  end

  def units_per_em
    @u_per_em ||= file.header.units_per_em
  end

  def horizontal_metrics
    @hm = file.horizontal_metrics
  end

  def glyph_id(character)
    character_code = character.unpack("U*").first
    file.cmap.unicode.first[character_code]
  end
end

# >> din = Font.new("#{File.dirname(__FILE__)}/../../fonts/DIN/DINPro-Light.ttf")
# >> din.width_of("Hypertension")
# => 5.832
# which is correct! Hypertension in that font takes up about 5.832 em! It's over by maybe ... 0.015.
