$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require "ttfunk"

file = TTFunk::File.new("data/fonts/DejaVuSans.ttf")
#p [:x_min, :y_min, :x_max, :y_max].map { |x| file.head.send(x) }
p file.hhea.length
p [:ascent, :descent].map {|x| file.hhea.send(x) }
