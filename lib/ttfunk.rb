require 'stringio'
require 'ttfunk/directory'
require 'ttfunk/resource_file'

module TTFunk
  class File
    attr_reader :contents
    attr_reader :directory

    def self.open(file)
      new(::File.open(file, "rb") { |f| f.read })
    end

    def self.from_dfont(file, which=0)
      new(ResourceFile.open(file) { |dfont| dfont["sfnt", which] })
    end

    def initialize(contents)
      @contents = StringIO.new(contents)
      @directory = Directory.new(@contents)
    end


    def ascent
      @ascent ||= (os2.exists? && os2.ascent && os2.ascent.nonzero?) || horizontal_header.ascent
    end

    def descent
      @descent ||= (os2.exists? && os2.descent && os2.descent.nonzero?) || horizontal_header.descent
    end

    def line_gap
      @line_gap ||= (os2.exists? && os2.line_gap && os2.line_gap.nonzero?) || horizontal_header.line_gap
    end

    def bbox
      [header.x_min, header.y_min, header.x_max, header.y_max]
    end


    def directory_info(tag)
      directory.tables[tag.to_s]
    end

    def header
      @header ||= TTFunk::Table::Head.new(self)
    end

    def cmap
      @cmap ||= TTFunk::Table::Cmap.new(self)
    end

    def horizontal_header
      @horizontal_header ||= TTFunk::Table::Hhea.new(self)
    end

    def horizontal_metrics
      @horizontal_metrics ||= TTFunk::Table::Hmtx.new(self)
    end

    def maximum_profile
      @maximum_profile ||= TTFunk::Table::Maxp.new(self)
    end

    def kerning
      @kerning ||= TTFunk::Table::Kern.new(self)
    end

    def name
      @name ||= TTFunk::Table::Name.new(self)
    end

    def os2
      @os2 ||= TTFunk::Table::OS2.new(self)
    end

    def postscript
      @postscript ||= TTFunk::Table::Post.new(self)
    end

    def glyph_locations
      @glyph_locations ||= TTFunk::Table::Loca.new(self)
    end

    def glyph_outlines
      @glyph_outlines ||= TTFunk::Table::Glyf.new(self)
    end
  end   
end

require "ttfunk/table/cmap"
require "ttfunk/table/glyf"
require "ttfunk/table/head"
require "ttfunk/table/hhea"
require "ttfunk/table/hmtx"
require "ttfunk/table/kern"
require "ttfunk/table/loca"
require "ttfunk/table/maxp"
require "ttfunk/table/name"
require "ttfunk/table/os2"
require "ttfunk/table/post"

