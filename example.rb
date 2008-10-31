$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require "ttfunk"

file = TTFunk::File.new("data/fonts/comicsans.ttf")
p file.maxp.num_glyphs