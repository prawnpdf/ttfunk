$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require "ttfunk"

file = TTFunk::File.new("data/fonts/gkai00mp.ttf")
p file.hmtx.lsb