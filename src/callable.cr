require "./interpreter.cr"

module Lox
  class Callable
    class Clock < Callable
      def arity : Int32
        0
      end

      def call(interpreter : Interpreter, arguments : Array(Bool | Nil | Float64 | String))
        Time.utc.to_unix_ms / 1000.0
      end

      def to_s
        "<native fn>"
      end
    end
  end
end
