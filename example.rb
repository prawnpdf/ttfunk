$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require "ttfunk"

file = TTFunk::File.new("data/fonts/comicsans.ttf")
file.cmap.formats[0]