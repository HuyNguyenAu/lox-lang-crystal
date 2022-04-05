require "./interpreter.cr"
require "./statement.cr"
require "./return-exception.cr"

module Lox
  abstract class Callable
    abstract def arity : Int32
    abstract def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Callable | Expression | String | Nil))
    abstract def to_s : String

    class Function < Callable
      def initialize(@declaration : Statement::Function, @closure : Environment)
      end

      def arity : Int32
        @declaration.parameters.size()
      end

      def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Callable | Expression | String | Nil))
        # The @closure creates an environment chain that goes from the function's body
        # through the environments where the functions are declared, and all the way
        # to the global scope.
        environment = Environment.new(@closure)

        i = 0
        @declaration.parameters.each() do |parameter|
          environment.define(parameter.lexeme, arguments[i])

          i += 1
        end

        begin
          interpreter.execute_block(@declaration.body, environment)
        rescue error : ReturnException
          return error.value
        end

        nil
      end

      def to_s : String
        "<fn #{@declaration.name.lexeme}>"
      end
    end

    class Clock < Callable
      def arity : Int32
        0
      end

      def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Callable | Expression | String | Nil))
        Time.utc.to_unix_ms / 1000.0
      end

      def to_s : String
        "<native fn>"
      end
    end
  end
end
