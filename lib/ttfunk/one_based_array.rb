module TTFunk
  class OneBasedArray < Array
    def [](idx)
      if idx == 0
        raise IndexError,
          "index #{idx} was outside the bounds of the array"
      end

      super(idx - 1)
    end
  end
end
