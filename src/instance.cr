require "./klass.cr"
require "./token.cr"
require "./runtime-exception.cr"

module Lox
  #
  class Instance
    def initialize(@klass : Klass)
      @fields = Hash(String, Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil).new
    end

    def get(name : Token) : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil
      if @fields.has_key?(name.lexeme)
        return @fields[name.lexeme]
      end

      # If we don't find a matching field, then we look for a method with that
      # name.
      method = @klass.find_method(name.lexeme)

      unless method.nil?
        return method.bind(self)
      end

      raise RuntimeException.new(name, "Undefined property '#{name.lexeme}'.")
    end

    def set(name : Token, value : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)
      @fields[name.lexeme] = value
    end

    def to_s : String
      "#{@klass.name} instance"
    end
  end
end
