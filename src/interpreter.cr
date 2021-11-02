require "../src/main.cr"
require "../src/expression.cr"
require "../src/token.cr"
require "../src/token-type.cr"
require "../src/runtime-exception.cr"

class Interpreter < Visitor
  def initialize
  end

  # Go through all statements and evaluate it.
  def interpret(statements : Array(Statement))
    begin
      i = 0
      while i < statements.size
        execute(statements[i])
        i += 1
      end
    rescue error : RuntimeException
      Program.runtime_error(error)
    end
  end

  # A binary expression evaluates to a value.
  # We need to evaluate the two operands with it's operator.
  def visit(expression : Binary) : Bool | Float64 | String | Nil
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

  # A grouping node contains a node which can be
  # recursively deep. We need to go into the expression
  # and evaluate the inner expression.
  def visit(expression : Grouping) : Bool | Float64 | String | Nil
    evaluate(expression.expression)
  end

  # Convert the literal syntax tree node into a runtime value.
  def visit(expression : Literal) : Bool | Float64 | String | Nil
    expression.value
  end

  # A unary an expression with a preceding '-' or '!'.
  def visit(expression : Unary) : Bool | Float64 | String | Nil
    right = evaluate(expression.right)

    case expression.operator.type
    when TokenType::BANG
      return is_truthy(right)
    when TokenType::MINUS
      check_number_operand(expression.operator, right)
      # Here we're meant to use double, but
      # Float64 is the same as double.
      return right.as(Float64)
    end

    # Unreachable.
    nil
  end

  # Statements produce no values. We only need to evaluate the
  # expression and then discard the result.
  def visit(statement : ExpressionStatement)
    evaluate(statement.expression)
  end

  # A print statement returns no value and only needs to print what the
  # statement expression evaluates to.
  def visit(statement : Print)
    value = evaluate(statement.expression)
    puts "#{stringify(value)}"
  end

  # Check if the operand is a Float64, otherwise raise a Runtime Exception.
  private def check_number_operand(operator : Token, operand : Bool | Float64 | String | Nil)
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

    raise RuntimeException.new(operator, "Operands must be a number.")
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
  private def stringify(object : Bool | Float64 | String | Nil) : String
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
  private def evaluate(expression : Expression) : Bool | Float64 | String | Nil
    expression.accept(self)
  end

  # Unwind the statement by send this statement back into
  # the interpreter's visitor implementation for statements.
  private def execute(statement : Statement)
    statement.accept(self)
  end
end
