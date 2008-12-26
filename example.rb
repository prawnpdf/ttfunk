$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require "ttfunk"

file = TTFunk::File.new("data/fonts/DejaVuSans.ttf")

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

puts "-- CHARACTER -> GLYPH LOOKUP ---------------"

character = "\xE2\x98\x9C"
puts "character     : #{character}"

character_code = character.unpack("U*").first
puts "character code: #{character_code}"

glyph_id = file.cmap.unicode.first[character_code]
puts "glyph id      : #{glyph_id}"

glyph_index = file.glyph_locations.index_of(glyph_id)
glyph_size  = file.glyph_locations.size_of(glyph_id)
puts "glyph index   : %d (%db)" % [glyph_index, glyph_size]

glyph = file.glyph_outlines.at(glyph_index)
puts "glyph         : (%d,%d)-(%d,%d) (%s)" % [glyph.x_min, glyph.y_min, glyph.x_max, glyph.y_max, glyph.class.name.split(/::/).last.downcase]
