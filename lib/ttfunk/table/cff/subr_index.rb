# frozen_string_literal: true

module TTFunk
  class Table
    class Cff < TTFunk::Table
      class SubrIndex < TTFunk::Table::Cff::Index
        def bias
          if items.length < 1240
            107
          elsif items.length < 33_900
            1131
          else
            32_768
          end
        end
      end
    end
  end
end
