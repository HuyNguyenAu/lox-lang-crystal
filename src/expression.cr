require "../src/token.cr"

# Basic Visitor pattern was adapted from https://github.com/crystal-community/crystal-patterns/blob/master/behavioral/visitor.cr.

abstract class Visitor
  # abstract def visit(expression : Assign)
  abstract def visit(expression : Binary) : Bool | Float64 | String | Nil
  # abstract def visit(expression : Call)
  # abstract def visit(expression : Gets)
  abstract def visit(expression : Grouping) : Bool | Float64 | String | Nil
  abstract def visit(expression : Literal) : Bool | Float64 | String | Nil
  # abstract def visit(expression : Logical)
  # abstract def visit(expression : Sets)
  # abstract def visit(expression : Super)
  # abstract def visit(expression : This)
  abstract def visit(expression : Unary) : Bool | Float64 | String | Nil
  # abstract def visit(expression : Variable)
end

abstract class Expression
  abstract def accept(vistor : Visitor) : Bool | Float64 | String | Nil
end

# class Assign < Expression
#   def initialize(@token : Token, @value : Expression)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end

#   def token
#     @token
#   end

#   def value
#     @value
#   end
# end

class Binary < Expression
  def initialize(@left : Expression, @operator : Token, @right : Expression)
  end

  def accept(visitor : Visitor) : Bool | Float64 | String | Nil
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

# class Call < Expression
#   def initialize(@callee : Expression, @paren : Token, @arguments : Array(Expression))
#   end

#   def accept(visitor : Visitor)
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

# class Gets < Expression
#   def initialize(@object : Expression, @name : Token)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end

#   def object
#     @object
#   end

#   def name
#     @name
#   end
# end

class Grouping < Expression
  def initialize(@expression : Expression)
  end

  def accept(visitor : Visitor) : Bool | Float64 | String | Nil
    visitor.visit(self)
  end

  def expression
    @expression
  end
end
 
class Literal < Expression
  def initialize(@value : Bool | Nil | Float64 | String)
  end

  def accept(visitor : Visitor) : Bool | Float64 | String | Nil
    visitor.visit(self)
  end

  def value
    @value
  end
end

# class Logical < Expression
#   def initialize(@left : Expression, @operator : Token, @right : Expression)
#   end

#   def accept(visitor : Visitor)
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

# class Sets < Expression
#   def initialize(@object : Expression, @name : Token, @value : Expression)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end
# end

# class Super < Expression
#   def initialize(@keyword : Token, @method : Token)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end
# end

# class This < Expression
#   def initialize(@keyword : Token)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end
# end

class Unary < Expression
  def initialize(@operator : Token, @right : Expression)
  end

  def accept(visitor : Visitor) : Bool | Float64 | String | Nil
    visitor.visit(self)
  end

  def operator
    @operator
  end

  def right
    @right
  end
end

# class Variable < Expression
#   def initialize(@name : Token)
#   end

#   def accept(visitor : Visitor)
#     visitor.visit(self)
#   end
# end
