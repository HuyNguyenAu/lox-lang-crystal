require "./main.cr"
require "./expression.cr"
require "./token.cr"
require "./token-type.cr"
require "./runtime-exception.cr"
require "./environment.cr"
require "./statement.cr"
require "./callable.cr"
require "./clock.cr"
require "./klass.cr"
require "./function.cr"
require "./instance.cr"

module Lox
  class Interpreter
    def initialize
      # Reference to the outermost global environment.
      @globals = Environment.new

      # Store the resolved local variables to determine later
      # if the variable is a local or global.
      @locals = Hash(Expression, Int32).new
      
      # The current environment.
      @environment = @globals

      @globals.define("clock", Lox::Clock.new())
    end

    def globals
      @globals
    end

    # Go through all statements and evaluate it.
    def interpret(statements : Array(Statement))
      begin
        statements.each do |statement|
          execute(statement)
        end
      rescue error : RuntimeException
        Program.runtime_error(error)
      end
    end

    # A block statement contains a series of statements (might be empty) or
    # declarations wrapped in curly braces.
    def visit_block_statement(statement : Statement::Block)
      execute_block(statement.statements, Environment.new(@environment))
      nil
    end

    # A class statement begins with a 'class' keyword followed by the
    # class name identifier.
    def visit_class_statement(statement : Statement::Class)
      @environment.define(statement.name.lexeme, nil)

      methods = Hash(String, Lox::Function).new()

      # Convert class methods into its AST nodes.
      statement.methods().each() do |method|
        function = Lox::Function.new(method, @environment)
        
        methods[method.name.lexeme] = function
      end
      
      klass = Klass.new(statement.name.lexeme, methods)

      @environment.assign(statement.name, klass)

      nil
    end
    # A binary expression evaluates to a value.
    # We need to evaluate the two operands with it's operator.
    def visit_binary_expression(expression : Expression)
      left = evaluate(expression.left)
      right = evaluate(expression.right)

      case expression.operator.type
      when TokenType::GREATER
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) > right.as(Float64)
      when TokenType::GREATER_EQUAL
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) >= right.as(Float64)
      when TokenType::LESS
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) < right.as(Float64)
      when TokenType::LESS_EQUAL
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) <= right.as(Float64)
      when TokenType::MINUS
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) - right.as(Float64)
      when TokenType::PLUS
        if left.is_a?(Float64) && right.is_a?(Float64)
          return left.as(Float64) + right.as(Float64)
        end

        if left.is_a?(String) && right.is_a?(String)
          return "#{left}#{right}"
        end

        raise RuntimeException.new(expression.operator, "Operands must be two numbers or two strings.")
      when TokenType::SLASH
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) / right.as(Float64)
      when TokenType::STAR
        check_number_operands(expression.operator, left, right)
        return left.as(Float64) * right.as(Float64)
      when TokenType::BANG_EQUAL
        return !is_equal(left, right)
      when TokenType::EQUAL_EQUAL
        return is_equal(left, right)
      end

      # Unreachable.
      nil
    end

    # Evaluate the expression for the callee and its arguments expressions and store
    # the results in a list. Invoke the call method with the results of the arguments.
    def visit_call_expression(expression : Expression)
      callee = evaluate(expression.callee)
      arguments = Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil).new()

      expression.arguments.each() do |argument|
        arguments << evaluate(argument)
      end

      unless callee.is_a?(Callable)
        raise RuntimeException.new(expression.paren, "Can only call functions and classes.")
      end

      function = callee.as(Callable)

      if arguments.size != function.arity
        raise RuntimeException.new(expression.paren, "Expected #{function.arity} arguments but got #{arguments.size}.")
      end

      function.call(self, arguments)
    end

    # Evaluate the expression whose property is being accessed.
    # Only instances of classes have properties.
    def visit_get_expression(expression : Expression::Get)
      object = evaluate(expression.object)

      # Look up the property.
      if object.is_a?(Instance)
        return object.as(Instance).get(expression.name)
      end

      raise RuntimeException.new(expression.name, "Only instances have properties.")
    end

    # A grouping node contains a node which can be
    # recursively deep. We need to go into the expression
    # and evaluate the inner expression.
    def visit_grouping_expression(expression : Expression)
      evaluate(expression.expression)
    end

    # Convert the literal syntax tree node into a runtime value.
    def visit_literal_expression(expression : Expression)
      expression.value
    end

    # Evaluate the left operand first to see if we can short-circuit.
    # If not, and only then,  can we evaluate the right operand.
    def visit_logical_expression(expression : Expression)
      left = evaluate(expression.left)

      if expression.operator.type == TokenType::OR
        return left unless !is_truthy(left)
      else
        return left unless is_truthy(left)
      end

      evaluate(expression.right)
    end

    # Evaluate the object whose property is being set.
    def visit_set_expression(expression : Expression::Set)
      object = evaluate(expression.object)

      if !object.is_a?(Instance)
        raise RuntimeException.new(expression.name, "Only instances have fields.")
      end

      value = evaluate(expression.value)
      object.as(Instance).set(expression.name, value)

      value
    end

    # A 'this' variable that will be treated as a variable.
    def visit_this_expression(expression : Expression::This)
      look_up_variable(expression.keyword, expression)
    end

    # A unary an expression with a preceding '-' or '!'.
    def visit_unary_expression(expression : Expression)
      right = evaluate(expression.right)

      case expression.operator.type
      when TokenType::BANG
        return !is_truthy(right)
      when TokenType::MINUS
        check_number_operand(expression.operator, right)
        # Here we're meant to use double, but
        # Float64 is the same as double.
        return -right.as(Float64)
      end

      # Unreachable.
      nil
    end

    # Forward the work to the environment which makes sure the
    # variable is defined.
    def visit_variable_expression(expression : Expression::Variable)
      look_up_variable(expression.name, expression)
    end

    # Look for a variable in the local and global variable space.
    private def look_up_variable(name : Token, expression : Expression)
      # Try to look for a local variable.
      distance = @locals[expression]?

      # If the local variable does not exist, then look for it in the
      # global variables.
      unless distance.nil?
        return @environment.get_at(distance, name.lexeme)
      else
        return @globals.get(name)
      end
    end

    # Evaluate the right hand side to get the value, then
    # store it in the named variable. If the variable scope
    # distance does not exist, then it is a global variable.
    def visit_assign_expression(expression : Expression::Assign)
      value = evaluate(expression.value)
      distance = @locals[expression]?

      if !distance.nil?
        @environment.assign_at(distance, expression.name, value)
      else
        @globals.assign(expression.name, value)
      end

      value
    end

    # Statements produce no values. We only need to evaluate the
    # expression and then discard the result.
    def visit_expression_statement(statement : Statement)
      evaluate(statement.expression)
      
      nil
    end

    # Store the the function in the current environment with the current
    # active environment when the function is declared, not when it's called.
    # A declaration binds the resulting object to a new
    # variable.
    def visit_function_statement(statement : Statement::Function)
      function = Lox::Function.new(statement, @environment)

      @environment.define(statement.name.lexeme, function)

      nil
    end

    # An if statment contains a must always contain a then branch statement.
    # An else branch statement is optional.
    def visit_if_statement(statement : Statement::If)
      if is_truthy(evaluate(statement.condition))
        execute(statement.then_branch)
      else
        else_branch = statement.else_branch
        execute(else_branch) unless else_branch.nil?
      end

      nil
    end

    # A print statement returns no value and only needs to print what the
    # statement expression evaluates to.
    def visit_print_statement(statement : Statement)
      value = evaluate(statement.expression)
      output = stringify(value)

      # Handle edge case where we need to show '-0' as '-0', not '0'.
      if statement.expression.is_a?(Expression::Unary) && value == 0
        puts "-#{output}"
      else
        puts output
      end

      nil
    end

    # We use an exception to unwind the interpreter past the visit methods of all
    # containg statements back to the code that started the executing body.
    def visit_return_statement(statement : Statement)
      statement_value = statement.value
      
      value = nil
      value = evaluate(statement_value) unless statement_value.nil?

      raise ReturnException.new(value)
    end

    # When we encounter a variable statement we need to store it in out current environment.
    def visit_variable_statement(statement : Statement)
      value = nil

      if statement.initialiser
        value = evaluate(statement.initialiser.as(Expression))
      end

      @environment.define(statement.name.lexeme, value)

      nil
    end

    # A while loop continues to execute the statement body as long as the
    # statement condition is true. But it evaulates the condition before
    # the body is executed.
    def visit_while_statement(statement : Statement::While)
      while is_truthy(evaluate(statement.condition))
        execute(statement.body)
      end

      nil
    end

    # Check if the operand is a Float64, otherwise raise a Runtime Exception.
    private def check_number_operand(operator : Token, operand)
      check = operand.is_a?(Float64)

      if !check.nil? && check
        return
      end

      raise RuntimeException.new(operator, "Operand must be a number.")
    end

    # Check if the left annd right operands are Float64, otherwise raise a Runtime Exception.
    private def check_number_operands(operator : Token, left, right)
      check_left = left.is_a?(Float64)
      check_right = right.is_a?(Float64)

      if !check_left.nil? && !check_right.nil? && check_left && check_right
        return
      end

      raise RuntimeException.new(operator, "Operands must be numbers.")
    end

    # Convert an object to bool. Nils are false.
    # All other non bool and non nil are true.
    private def is_truthy(object) : Bool
      if object.nil?
        return false
      end

      if object.is_a?(Bool)
        return object.as(Bool)
      end

      true
    end

    # Check if two objects are equal in type and value.
    private def is_equal(a, b) : Bool
      if a.nil? && b.nil?
        return true
      end

      if a.nil?
        return false
      end

      # Crystal does not have a.equals(b).
      # This should be good enough.
      a.is_a?(typeof(b)) && a == b
    end

    # Convert and object to string.
    private def stringify(object) : String
      if object.nil?
        return "nil"
      end

      check = object.is_a?(Float64)

      if !check.nil? && check
        text = "#{object}"

        if text.ends_with?(".0")
          text = text[0, text.size - 2]
        end

        return text
      end

      "#{object}"
    end

    # Unwind the expression by send this expression back into
    # the interpreter's visitor implementation for expressions.
    private def evaluate(expression : Expression)
      expression.accept(self)
    end

    # Unwind the statement by send this statement back into
    # the interpreter's visitor implementation for statements.
    private def execute(statement : Statement)
      statement.accept(self)
    end

    def resolve(expression : Expression, depth : Int32)
      @locals[expression] = depth
    end

    # Execute a list of statements of a given environment (scope).
    # Then restore the environment previously.
    def execute_block(statements : Array(Statement), environment : Environment)
      previous : Environment = @environment

      begin
        @environment = environment

        statements.each do |statement|
          execute(statement)
        end
      ensure
        @environment = previous
      end
    end
  end
end
