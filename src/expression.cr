require "../src/token.cr"

module Lox
  abstract class Expression
    # class Assign < Expression
    #   def initialize(@token : Token, @value : Expression)
    #   end

    #   def accept(visitor)
    #     visitor.visit_assign_expression(self)
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

      def accept(visitor)
        visitor.visit_binary_expression(self)
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

    class Grouping < Expression
      def initialize(@expression : Expression)
      end

      def accept(visitor)
        visitor.visit_grouping_expression(self)
      end

      def expression
        @expression
      end
    end

    class Literal < Expression
      def initialize(@value : Bool | Nil | Float64 | String)
      end

      def accept(visitor)
        visitor.visit_literal_expression(self)
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

    class Unary < Expression
      def initialize(@operator : Token, @right : Expression)
      end

      def accept(visitor)
        visitor.visit_unary_expression(self)
      end

      def operator
        @operator
      end

      def right
        @right
      end
    end

    class Variable < Expression
      def initialize(@name : Token)
      end

      def accept(visitor)
        visitor.visit_variable_expression(self)
      end

      def name
        @name
      end
    end
  end
end
