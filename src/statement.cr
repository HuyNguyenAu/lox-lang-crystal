require "../src/token.cr"

# Basic Visitor pattern was adapted from https://github.com/crystal-community/crystal-patterns/blob/master/behavioral/visitor.cr.

abstract class Visitor
  # abstract def visit(statement : Block)
  # abstract def visit(statement : Class)
  abstract def visit(statement : ExpressionStatement)
  # abstract def visit(statement : Function)
  # abstract def visit(statement : If)
  abstract def visit(statement : Print)
  # abstract def visit(statement : Return)
  abstract def visit(statement : Var)
  # abstract def visit(statement : While)
end

abstract class Statement
  abstract def accept(vistor : Visitor)
end

# class Block < Statement
#   def initialize(@statements : Array(Statement))
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end

#   def statements
#     @statements
#   end
# end

# class Class < Statement
#   def initialize(@name : Token, superclass : Variable, methods : Array(Function))
#   end

#   def accept(visitor : Visitor)
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

  def accept(visitor : Visitor)
    visitor.visit(self)
  end

  def expression
    @expression
  end
end

# class Function < Statement
#   def initialize(@name : Token, params : Array(Token), body : Array(Statement))
#   end

#   def accept(visitor : Visitor)
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

# class If < Statement
#   def initialize(@condition : Expression, then_branch : Statement, else_branch : Statement)
#   end

#   def accept(visitor : Visitor)
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

class Print < Statement
  def initialize(@expression : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end

  def expression
    @expression
  end
end

# class Return < Statement
#   def initialize(@keyword : Token, @value : Expression)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end

#   def keyword
#     @keyword
#   end

#   def value
#     @value
#   end
# end

class Var < Statement
  def initialize(@name : Token, @initialiser : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end

  def name
    @name
  end

  def initialiser
    @initialiser
  end
end

# class While < Statement
#   def initialize(@condition : Expression, @body : Statement)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end

#   def condition
#     @condition
#   end

#   def body
#     @body
#   end
# end
