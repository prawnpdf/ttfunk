require 'ttfunk/reader'

module TTFunk
  class Table
    class Kern
      class Format0
        include Reader

        attr_reader :attributes
        attr_reader :pairs

        def initialize(attributes={})
          @file = file
          @attributes = attributes

          num_pairs, search_range, entry_selector, range_shift, *pairs =
            attributes.delete(:data).unpack("n*")

          @pairs = {}
          num_pairs.times do |i|
            left = pairs[i*3]
            right = pairs[i*3+1]
            value = to_signed(pairs[i*3+2])
            @pairs[[left, right]] = value
          end
        end

        def vertical?
          @attributes[:vertical]
        end

        def horizontal?
          !vertical?
        end

        def cross_stream?
          @attributes[:cross]
        end
      end
    end
  end
end
