require "../src/expression.cr"
require "../src/token.cr"
require "../src/token-type.cr"

class ASTPrinter < Visitor
  def print(expression : Expression) : String
    expression.accept(self)
  end

  def visit(expression : Binary) : String
    parenthesise(expression.operator.lexeme, [expression.left, expression.right])
  end

  def visit(expression : Grouping) : String
    parenthesise("group", [expression.expression])
  end

  def visit(expression : Literal) : String
    # We need to conform to Java's null as a string behaviour.
    if expression.value.nil?
      return "null"
    end

    "#{expression.value}"
  end

  def visit(expression : Unary) : String
    parenthesise(expression.operator.lexeme, [expression.right])
  end

  def parenthesise(name : String, expressions : Array(Expression)) : String
    builder = "(#{name}"

    i = 0
    while true
        if i > expressions.size - 1
            break
        end
        expression = expressions[i]
        builder += " #{expression.accept(self)}"
        i += 1
    end

    builder += ")"

    builder
  end
end
