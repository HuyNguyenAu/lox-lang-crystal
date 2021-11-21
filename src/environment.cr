require "../src/token.cr"
require "../src/runtime-exception.cr"

module Lox
  class Environment
    @values = Hash(String, Bool | Float64 | String | Nil).new

    # Try to get and return a variable by token.
    def get(name : Token) : Bool | Float64 | String | Nil
      if @values.has_key?(name.lexeme)
        return @values[name.lexeme]
      end

      raise RuntimeException.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    # Add a new variable(binding) to the current enviroment.
    def define(name : String, value : Bool | Float64 | String | Nil)
      @values[name] = value
    end
  end
end
