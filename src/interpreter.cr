require "../src/main.cr"
require "../src/expression.cr"
require "../src/token.cr"
require "../src/token-type.cr"
require "../src/runtime-exception.cr"

class Interpreter < Visitor
  def initialize
  end

  def interpret(expression : Expression)
    begin
      value = stringify(evaluate(expression))
      puts "#{value}"
    rescue error : RuntimeException
      Program.runtime_error(error)
    end
  end

  def visit(expression : Binary)
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
        return left.as(Float64) - right.as(Float64)
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
  def visit(expression : Grouping)
    evaluate(expression.expression)
  end

  # Convert the literal syntax tree node into a runtime value.
  def visit(expression : Literal)
    expression.value
  end

  # A unary an expression with a preceding '-' or '!'.
  def visit(expression : Unary)
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

  # Check if the operand is a Float64, otherwise raise a Runtime Exception.
  private def check_number_operand(operator : Token, operand : Bool | Float64 | String | Nil)
    check : Bool | Nil = operand.is_a?(Float64)

    if !check.nil? && check
      return
    end

    raise RuntimeException.new(operator, "Operand must be a number.")
  end

  # Check if the left annd right operands are Float64, otherwise raise a Runtime Exception.
  private def check_number_operands(operator : Token, left, right)
    check_left : Bool | Nil = left.is_a?(Float64)
    check_right : Bool | Nil = right.is_a?(Float64)

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
  private def stringify(object) : String
    if object.nil?
      return "nil"
    end

    check : Bool | Nil = object.is_a?(Float64)

    if !check.nil? && check
      text : String = "#{object}"

      if text.ends_with?(".0")
        text = text[0, text.size - 2]
      end

      return text
    end

    "#{object}"
  end

  # Unwind the expression by send this expression back into
  # the interpreter's visitor implementation.
  private def evaluate(expression : Expression)
    expression.accept(self)
  end
end
