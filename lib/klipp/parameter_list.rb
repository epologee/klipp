module Klipp
  class ParameterList < Array
    def options
      select { |x| x.to_s[0, 1] == '-' }
    end

    def arguments
      self - options
    end

    #def splice_option(name)
    #  !!delete(name)
    #end

    def shift_argument
      (arg = arguments[0]) && delete(arg)
    end
  end
end