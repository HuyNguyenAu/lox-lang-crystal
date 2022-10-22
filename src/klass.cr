require "./callable.cr"
require "./instance.cr"

module Lox
  #
  class Klass < Callable
    def initialize(@name : String)
    end

    def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)) : Lox::Instance
      instance = Instance.new(self)
      instance
    end

    def arity : Int32
      0
    end

    def name : String
      @name
    end

    def to_s : String
      @name
    end
  end
end