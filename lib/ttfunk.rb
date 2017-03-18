require 'stringio'
require 'pathname'

require 'ttfunk/directory'
require 'ttfunk/resource_file'
require 'ttfunk/collection'

module TTFunk
  class File
    attr_reader :contents
    attr_reader :directory

    def self.open(io_or_path)
      new verify_and_open(io_or_path).read
    end

    def self.from_dfont(file, which = 0)
      new(ResourceFile.open(file) { |dfont| dfont['sfnt', which] })
    end

    def self.from_ttc(file, which = 0)
      Collection.open(file) { |ttc| ttc[which] }
    end

    def self.verify_and_open(io_or_path)
      # File or IO
      if io_or_path.respond_to?(:rewind)
        io = io_or_path
        # Rewind if the object we're passed is an IO, so that multiple embeds of
        # the same IO object will work
        io.rewind
        # read the file as binary so the size is calculated correctly
        # guard binmode because some objects acting io-like don't implement it
        io.binmode if io.respond_to?(:binmode)
        return io
      end
      # String or Pathname
      io_or_path = Pathname.new(io_or_path)
      raise ArgumentError, "#{io_or_path} not found" unless io_or_path.file?
      io = io_or_path.open('rb')
      io
    end

    def initialize(contents, offset = 0)
      @contents = StringIO.new(contents)
      @directory = Directory.new(@contents, offset)
    end

    def ascent
      @ascent ||= (os2.exists? && os2.ascent && os2.ascent.nonzero?) ||
        horizontal_header.ascent
    end

    def descent
      @descent ||= (os2.exists? && os2.descent && os2.descent.nonzero?) ||
        horizontal_header.descent
    end

    def line_gap
      @line_gap ||= (os2.exists? && os2.line_gap && os2.line_gap.nonzero?) ||
        horizontal_header.line_gap
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

    def sbix
      @sbix ||= TTFunk::Table::Sbix.new(self)
    end
  end
end

require 'ttfunk/reader'
require 'ttfunk/table'

require 'ttfunk/table/cmap'
require 'ttfunk/table/cmap/format00'
require 'ttfunk/table/cmap/format04'
require 'ttfunk/table/cmap/format06'
require 'ttfunk/table/cmap/format10'
require 'ttfunk/table/cmap/format12'
require 'ttfunk/table/cmap/subtable'

require 'ttfunk/table/glyf'
require 'ttfunk/table/glyf/compound'
require 'ttfunk/table/glyf/simple'

require 'ttfunk/table/head'
require 'ttfunk/table/hhea'
require 'ttfunk/table/hmtx'

require 'ttfunk/table/kern'
require 'ttfunk/table/kern/format0'

require 'ttfunk/table/loca'
require 'ttfunk/table/maxp'
require 'ttfunk/table/name'
require 'ttfunk/table/os2'

require 'ttfunk/table/post'
require 'ttfunk/table/post/format10'
require 'ttfunk/table/post/format20'
require 'ttfunk/table/post/format30'
require 'ttfunk/table/post/format40'

require 'ttfunk/table/simple'
require 'ttfunk/table/sbix'

require 'ttfunk/encoding/mac_roman'
require 'ttfunk/encoding/windows_1252'

require 'ttfunk/subset'
require 'ttfunk/subset/base'
require 'ttfunk/subset/unicode'
require 'ttfunk/subset/unicode_8bit'
require 'ttfunk/subset/windows_1252'
require 'ttfunk/subset/mac_roman'

