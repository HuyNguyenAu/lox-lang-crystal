require "../src/token.cr"

# Basic Visitor pattern was adapted from https://github.com/crystal-community/crystal-patterns/blob/master/behavioral/visitor.cr.
module Lox
  abstract class Visitor(T)
    # abstract def visit(expression : AssignExpression) : T
    abstract def visit(expression : BinaryExpression) : T
    # abstract def visit(expression : CallExpression) : T
    # abstract def visit(expression : GetsExpression) : T
    abstract def visit(expression : GroupingExpression) : T
    abstract def visit(expression : LiteralExpression) : T
    # abstract def visit(expression : LogicalExpression) : T
    # abstract def visit(expression : SetsExpression) : T
    # abstract def visit(expression : SuperExpression) : T
    # abstract def visit(expression : ThisExpression) : T
    abstract def visit(expression : UnaryExpression) : T
    abstract def visit(expression : VariableExpression) : T
  end

  abstract class Expression
    abstract def accept(visitor : Visitor)
  end

  # class AssignExpression < Expression
  #   def initialize(@token : Token, @value : Expression)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def token
  #     @token
  #   end

  #   def value
  #     @value
  #   end
  # end

  class BinaryExpression < Expression
    def initialize(@left : Expression, @operator : Token, @right : Expression)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def left
      @left
    end

    def operator
      @operator
    end

    def right
      @right
    end
  end

  # class CallExpression < Expression
  #   def initialize(@callee : Expression, @paren : Token, @arguments : Array(Expression))
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def callee
  #     @callee
  #   end

  #   def paren
  #     @paren
  #   end

  #   def arguments
  #     @arguments
  #   end
  # end

  # class GetsExpression < Expression
  #   def initialize(@object : Expression, @name : Token)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def object
  #     @object
  #   end

  #   def name
  #     @name
  #   end
  # end

  class GroupingExpression < Expression
    def initialize(@expression : Expression)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def expression
      @expression
    end
  end

  class LiteralExpression < Expression
    def initialize(@value : Bool | Nil | Float64 | String)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def value
      @value
    end
  end

  # class LogicalExpression < Expression
  #   def initialize(@left : Expression, @operator : Token, @right : Expression)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def left
  #     @left
  #   end

  #   def operator
  #     @operator
  #   end

  #   def right
  #     @right
  #   end
  # end

  # class SetsExpression < Expression
  #   def initialize(@object : Expression, @name : Token, @value : Expression)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end
  # end

  # class SuperExpression < Expression
  #   def initialize(@keyword : Token, @method : Token)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end
  # end

  # class ThisExpression < Expression
  #   def initialize(@keyword : Token)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end
  # end

  class UnaryExpression < Expression
    def initialize(@operator : Token, @right : Expression)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def operator
      @operator
    end

    def right
      @right
    end
  end

  class VariableExpression < Expression
    def initialize(@name : Token)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def name
      @name
    end
  end
end
