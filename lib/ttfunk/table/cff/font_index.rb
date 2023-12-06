# frozen_string_literal: true

module TTFunk
  class Table
    class Cff < TTFunk::Table
      class FontIndex < TTFunk::Table::Cff::Index
        attr_reader :top_dict

        def initialize(top_dict, file, offset, length = nil)
          super(file, offset, length)
          @top_dict = top_dict
        end

        def finalize(new_cff_data)
          each { |font_dict| font_dict.finalize(new_cff_data) }
        end

        private

        def decode_item(_index, offset, length)
          TTFunk::Table::Cff::FontDict.new(
            top_dict, file, offset, length
          )
        end

        def encode_items(*)
          # Re-encode font dicts
          map(&:encode)
        end
      end
    end
  end
end
