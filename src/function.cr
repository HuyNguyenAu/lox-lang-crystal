require "./callable.cr"
require "./statement.cr"
require "./environment.cr"

module Lox
  class Function < Callable
    def initialize(@declaration : Statement::Function, @closure : Environment)
    end

    def arity : Int32
      @declaration.parameters.size
    end

    # Each function call gets its own enviroment to ensure recursion will not break due to multiple calls
    # to the same function.
    def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil))
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
end
