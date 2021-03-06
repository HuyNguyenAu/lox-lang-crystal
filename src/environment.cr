require "../src/token.cr"
require "../src/callable.cr"
require "../src/runtime-exception.cr"

module Lox
  class Environment
    @values = Hash(String, Bool | Float64 | Callable | Expression | String | Nil).new()

    def initialize(@enclosing : Environment | Nil  = nil)
    end

    # Try to get and return a variable by token.
    def get(name : Token) : Bool | Float64 | Callable | Expression | String | Nil
      if @values.has_key?(name.lexeme)
        return @values[name.lexeme]
      end

      return @enclosing.as(Environment).get(name) unless @enclosing.nil?

      raise RuntimeException.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    # Add a new variable(binding) to the current environment.
    def define(name : String, value : Bool | Float64 | Callable | Expression | String | Nil)
      @values[name] = value
    end

    # Update a variable with a new value in the current environment.
    def assign(name : Token, value)
      if @values.has_key?(name.lexeme)
        @values[name.lexeme] = value
        return
      end

      unless @enclosing.nil?
        @enclosing.as(Environment).assign(name, value)
        return
      end

      raise RuntimeException.new(name, "Undefined variable '#{name.lexeme}'.")
    end
  end
end
