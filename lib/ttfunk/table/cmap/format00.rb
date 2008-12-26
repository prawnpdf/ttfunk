module TTFunk
  class Table
    class Cmap

      module Format00
        attr_reader :language
        attr_reader :code_map

        def [](code)
          @code_map[code] || 0
        end

        def supported?
          true
        end

        private

          def parse_cmap!
            length, @language = read(6, "nn")
            @code_map = read(256, "C*")
          end
      end

    end
  end
end
