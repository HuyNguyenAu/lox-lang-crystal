require "./callable.cr"
require "./function.cr"
require "./instance.cr"

module Lox
  #
  class Klass < Callable
    def initialize(@name : String, @methods : Hash(String, Lox::Function))
    end

    def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)) : Lox::Instance
      instance = Instance.new(self)

      instance
    end

    def find_method(name : String) : Lox::Function | Nil
      if @methods.has_key?(name)
        return @methods[name]
      end

      nil
    end

    def name : String
      @name
    end

    def methods : String
      @methods
    end

    def arity : Int32
      0
    end

    def to_s : String
      @name
    end
  end
end
