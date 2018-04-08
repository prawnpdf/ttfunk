module TTFunk
  class Sci
    attr_reader :significand, :exponent

    def initialize(significand, exponent)
      @significand = significand
      @exponent = exponent
    end

    def to_f
      significand * 10**exponent
    end
  end
end
