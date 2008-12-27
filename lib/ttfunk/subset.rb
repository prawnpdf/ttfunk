require 'set'
require 'ttfunk/table/cmap'
require 'ttfunk/table/glyf'
require 'ttfunk/table/hmtx'
require 'ttfunk/table/kern'
require 'ttfunk/table/loca'

module TTFunk
  class Subset
    attr_reader :original

    def initialize(original)
      @original = original
      @subset = Set.new([0])
    end

    def use(characters)
      @subset.merge(characters)
    end

    def encode
      cmap = original.cmap.unicode.first

      charmap = @subset.inject({}) { |map, code| map[code] = cmap[code]; map }
      cmap_table = TTFunk::Table::Cmap.encode(charmap)

      glyph_ids = @subset.map { |character| cmap[character] }
      glyphs = collect_glyphs(glyph_ids)

      old2new_glyph = cmap_table[:charmap].inject({}) { |map, (code, ids)| map[ids[:old]] = ids[:new]; map }
      next_glyph_id = cmap_table[:max_glyph_id]

      glyphs.keys.each do |old_id|
        unless old2new_glyph.key?(old_id) 
          old2new_glyph[old_id] = next_glyph_id
          next_glyph_id += 1
        end
      end

      new2old_glyph = old2new_glyph.invert

      glyf_table = TTFunk::Table::Glyf.encode(glyphs, new2old_glyph, old2new_glyph)
      loca_table = TTFunk::Table::Loca.encode(glyf_table[:offsets])
      kern_table = TTFunk::Table::Kern.encode(original.kerning, old2new_glyph)
      hmtx_table = TTFunk::Table::Hmtx.encode(original.horizontal_metrics, new2old_glyph)
      hhea_table = TTFunk::Table::Hhea.encode(original.horizontal_header, hmtx_table)
      maxp_table = TTFunk::Table::Maxp.encode(original.maximum_profile, old2new_glyph)
      os2_table  = original.os2.raw
      post_table = TTFunk::Table::Post.encode(original.postscript, new2old_glyph)
      name_table = TTFunk::Table::Name.encode(original.name)
      head_table = TTFunk::Table::Head.encode(original.header, loca_table)

      tables = { 'cmap' => cmap_table[:table],
                 'glyf' => glyf_table[:table],
                 'loca' => loca_table[:table],
                 'kern' => kern_table,
                 'hmtx' => hmtx_table[:table],
                 'hhea' => hhea_table,
                 'maxp' => maxp_table,
                 'OS/2' => os2_table,
                 'post' => post_table,
                 'name' => name_table,
                 'head' => head_table }

      tables.delete_if { |tag, table| table.nil? }

      search_range = (Math.log(tables.length) / Math.log(2)).to_i * 16
      entry_selector = (Math.log(search_range) / Math.log(2)).to_i
      range_shift = tables.length * 16 - search_range

      newfont = [original.directory.scaler_type, tables.length, search_range, entry_selector, range_shift].pack("Nn*")

      directory_size = tables.length * 16
      offset = newfont.length + directory_size

      table_data = ""
      head_offset = nil
      tables.each do |tag, data|
        newfont << [tag, checksum(data), offset, data.length].pack("A4N*")
        table_data << data
        head_offset = offset if tag == 'head'
        offset += data.length
        while offset % 4 != 0
          offset += 1
          table_data << "\0"
        end
      end

      newfont << table_data
      sum = checksum(newfont)
      adjustment = 0xB1B0AFBA - sum
      newfont[head_offset+8,4] = [adjustment].pack("N")

      return newfont
    end

    private

      def checksum(data)
        data += "\0" * (4 - data.length % 4) unless data.length % 4 == 0
        data.unpack("N*").inject(0) { |sum, dword| sum + dword } & 0xFFFF_FFFF
      end

      def collect_glyphs(glyph_ids)
        glyphs = glyph_ids.inject({}) { |h, id| h[id] = original.glyph_outlines.for(id); h }
        additional_ids = glyphs.values.select { |g| g && g.compound? }.map { |g| g.glyph_ids }.flatten

        glyphs.update(collect_glyphs(additional_ids)) if additional_ids.any?

        return glyphs
      end
  end
end
