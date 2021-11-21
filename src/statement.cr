require "../src/token.cr"

# Basic Visitor pattern was adapted from https://github.com/crystal-community/crystal-patterns/blob/master/behavioral/visitor.cr.
module Lox
  abstract class Visitor(T)
    # abstract def visit(statement : BlockStatement) : T
    # abstract def visit(statement : ClassStatement) : T
    abstract def visit(statement : ExpressionStatement) : T
    # abstract def visit(statement : FunctionStatement) : T
    # abstract def visit(statement : IfStatement) : T
    abstract def visit(statement : PrintStatement) : T
    # abstract def visit(statement : ReturnStatement) : T
    abstract def visit(statement : VariableStatement) : T
    # abstract def visit(statement : WhileStatement) : T
  end

  abstract class Statement
    abstract def accept(visitor : Visitor)
  end

  # class Block < Statement
  #   def initialize(@statements : Array(Statement))
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def statements
  #     @statements
  #   end
  # end

  # class Class < Statement
  #   def initialize(@name : Token, superclass : Variable, methods : Array(Function))
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def name
  #     @name
  #   end

  #   def superclass
  #     @superclass
  #   end

  #   def methods
  #     @methods
  #   end
  # end

  class ExpressionStatement < Statement
    def initialize(@expression : Expression)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def expression
      @expression
    end
  end

  # class FunctionStatement < Statement
  #   def initialize(@name : Token, params : Array(Token), body : Array(Statement))
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def name
  #     @name
  #   end

  #   def params
  #     @params
  #   end

  #   def body
  #     @body
  #   end
  # end

  # class IfStatement < Statement
  #   def initialize(@condition : Expression, then_branch : Statement, else_branch : Statement)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def condition
  #     @condition
  #   end

  #   def then_branch
  #     @then_branch
  #   end

  #   def else_branch
  #     @else_branch
  #   end
  # end

  class PrintStatement < Statement
    def initialize(@expression : Expression)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def expression
      @expression
    end
  end

  # class ReturnStatement < Statement
  #   def initialize(@keyword : Token, @value : Expression)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def keyword
  #     @keyword
  #   end

  #   def value
  #     @value
  #   end
  # end

  class VariableStatement < Statement
    def initialize(@name : Token, @initialiser : Expression)
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def name
      @name
    end

    def initialiser
      @initialiser
    end
  end

  class EmptyStatement < Statement
    def accept(visitor)
    end
  end

  # class WhileStatement < Statement
  #   def initialize(@condition : Expression, @body : Statement)
  #   end

  #   def accept(visitor)
  #     visitor.visit(self)
  #   end

  #   def condition
  #     @condition
  #   end

  #   def body
  #     @body
  #   end
  # end
end
