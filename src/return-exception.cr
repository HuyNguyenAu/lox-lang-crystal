require "./token.cr"
require "./callable.cr"

module Lox
  class ReturnException < Exception
    def initialize(@value : Bool | Float64 | Callable | Expression | String | Nil)
    end

    def value
      @value
    end
  end
end
