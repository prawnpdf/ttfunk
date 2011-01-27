# encoding: utf-8
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib"
require "ttfunk"

def character_lookup(file, character)
  puts "character     : #{character}"

  character_code = character.unpack("U*").first
  puts "character code: #{character_code}"

  glyph_id = file.cmap.unicode.first[character_code]
  puts "glyph id      : #{glyph_id}"

  glyph = file.glyph_outlines.for(glyph_id)
  puts "glyph type    : %s" % glyph.class.name.split(/::/).last.downcase
  puts "glyph size    : %db" % glyph.raw.length
  puts "glyph bbox    : (%d,%d)-(%d,%d)" % [glyph.x_min, glyph.y_min, glyph.x_max, glyph.y_max]

  if glyph.compound?
    puts "components    : %d %s" % [glyph.glyph_ids.length, glyph.glyph_ids.inspect]
  end
end

file = TTFunk::File.open(ARGV.first || "#{File.dirname(__FILE__)}/../data/fonts/DejaVuSans.ttf")

puts "-- FONT ------------------------------------"

puts "revision  : %08x" % file.header.font_revision
puts "name      : #{file.name.font_name.join(', ')}"
puts "family    : #{file.name.font_family.join(', ')}"
puts "subfamily : #{file.name.font_subfamily.join(', ')}"
puts "postscript: #{file.name.postscript_name}"

puts "-- FONT METRICS ----------------------------"

puts "units/em  : #{file.header.units_per_em}"
puts "ascent    : #{file.ascent}"
puts "descent   : #{file.descent}"
puts "line gap  : #{file.line_gap}"
puts "bbox      : (%d,%d)-(%d,%d)" % file.bbox

puts "-- SIMPLE CHARACTER -> GLYPH LOOKUP --------"
character_lookup(file, "\xE2\x98\x9C")

puts "-- COMPOUND CHARACTER -> GLYPH LOOKUP ------"
character_lookup(file, "ë")
