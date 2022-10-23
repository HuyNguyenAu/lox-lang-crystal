require "./callable.cr"
require "./statement.cr"
require "./environment.cr"

module Lox
  class Function < Callable
    def initialize(@declaration : Statement::Function, @closure : Environment, @is_initialiser : Bool)
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
        # Sometimes using an empty early return is useful. So in this case,
        # we can allow it.
        if @is_initialiser
          return @closure.get_at(0, "this")
        end

        return error.value
      end

      # If the class 'init' method is called, return the class's 'this'.
      if @is_initialiser
        return @closure.get_at(0, "this")
      end

      nil
    end

    def bind(instance : Lox::Instance) : Lox::Function
      environment = Environment.new(@closure)
      environment.define("this", instance)

      # Create a closure that binds 'this' to a method.
      Lox::Function.new(@declaration, environment, @is_initialiser)
    end

    def to_s : String
      "<fn #{@declaration.name.lexeme}>"
    end
  end
end
