module Lox
  # A clock class used to measure performace.
  class Clock < Callable
    def arity : Int32
      0
    end

    def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil))
      Time.utc.to_unix_ms / 1000.0
    end

    def to_s : String
      "<native fn>"
    end
  end
end
