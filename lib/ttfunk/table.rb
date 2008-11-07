%w[cmap head hhea hmtx name directory].each do |lib|
  require "ttfunk/table/" + lib
end

module TTFunk
  class Table
    def method_missing(*args, &block)
      var = "@#{args.first}"
      instance_variables.include?(var) ? instance_variable_get(var) : super
    end
    
    private
    
    def to_signed(n, length=16)
      max = 2**length-1
      mid = 2**(length-1)
      (n>=mid) ? -((n ^ max) + 1) : n
    end
  end
end
