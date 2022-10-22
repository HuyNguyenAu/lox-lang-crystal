require "./token.cr"
require "./callable.cr"

module Lox
  class ReturnException < Exception
    def initialize(@value : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)
    end

    def value
      @value
    end
  end
end
