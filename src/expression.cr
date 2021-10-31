require "../src/token.cr"

abstract class Visitor
  abstract def visit(expression : Assign)
  abstract def visit(expression : Binary)
  abstract def visit(expression : Call)
  abstract def visit(expression : Get)
  abstract def visit(expression : Group)
  abstract def visit(expression : Literal)
  abstract def visit(expression : Logical)
  abstract def visit(expression : Set)
  abstract def visit(expression : Super)
  abstract def visit(expression : This)
  abstract def visit(expression : Unary)
  abstract def visit(expression : Variable)
end

abstract class Expression
  abstract def accept(vistor : Visitor)
end

class Assign < Expression
  def initialize(@token : Token, @value : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Binary < Expression
  def initialize(@left : Expression, @operator : Token, @right : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Call < Expression
  def initialize(@callee : Expression, @paren : Token, @arguments : Array(Expression))
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Gets < Expression
  def initialize(@object : Expression, @name : Token)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Grouping < Expression
  def initialize(@expression : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Literal < Expression
  def initialize(@value : Bool | Nil | Float64 | String)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Logical < Expression
  def initialize(@left : Expression, @operator : Token, @right : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Sets < Expression
  def initialize(@object : Expression, @name : Token, @value : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Super < Expression
  def initialize(@keyword : Token, @method : Token)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class This < Expression
  def initialize(@keyword : Token)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Unary < Expression
  def initialize(@operator : Token, @right : Expression)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end

class Variable < Expression
  def initialize(@name : Token)
  end

  def accept(visitor : Visitor)
    visitor.visit(self)
  end
end
