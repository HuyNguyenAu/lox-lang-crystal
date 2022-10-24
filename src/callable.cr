require "./interpreter.cr"
require "./statement.cr"
require "./return-exception.cr"

module Lox
  # An interface for handling named functions.
  abstract class Callable
    # Get the number of parameters a function expects.
    abstract def arity : Int32
    # Execute the function call.
    abstract def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil))
    # A nicer output for the user to view the function value.
    abstract def to_s : String
  end
end
