require "../src/token.cr"
require "../src/expression.cr"

# Basic Visitor pattern was adapted from https://github.com/crystal-community/crystal-patterns/blob/master/behavioral/visitor.cr.
module Lox
  abstract class Statement
    abstract def accept(visitor)

    class Block < Statement
      def initialize(@statements : Array(Statement))
      end

      def accept(visitor)
        visitor.visit_block_statement(self)
      end

      def statements
        @statements
      end
    end

    class Class < Statement
      # def initialize(@name : Token, superclass : Variable, methods : Array(Function))
      def initialize(@name : Token, methods : Array(Function))
      end

      def accept(visitor)
        visitor.visit_class_statement(self)
      end

      def name
        @name
      end

      # def superclass
      #   @superclass
      # end

      def methods
        @methods
      end
    end

    class Expression < Statement
      def initialize(@expression : Lox::Expression)
      end

      def accept(visitor)
        visitor.visit_expression_statement(self)
      end

      def expression
        @expression
      end
    end

    class Function < Statement
      def initialize(@name : Token, @parameters : Array(Token), @body : Array(Statement))
      end

      def accept(visitor)
        visitor.visit_function_statement(self)
      end

      def name
        @name
      end

      def parameters
        @parameters
      end

      def body
        @body
      end
    end

    class If < Statement
      def initialize(@condition : Lox::Expression, @then_branch : Statement, @else_branch : Statement | Nil)
      end

      def accept(visitor)
        visitor.visit_if_statement(self)
      end

      def condition
        @condition
      end

      def then_branch
        @then_branch
      end

      def else_branch
        @else_branch
      end
    end

    class Print < Statement
      def initialize(@expression : Lox::Expression)
      end

      def accept(visitor)
        visitor.visit_print_statement(self)
      end

      def expression
        @expression
      end
    end

    class Return < Statement
      def initialize(@keyword : Token, @value : Lox::Expression | Nil)
      end

      def accept(visitor)
        visitor.visit_return_statement(self)
      end

      def keyword
        @keyword
      end

      def value
        @value
      end
    end

    class Variable < Statement
      def initialize(@name : Token, @initialiser : Lox::Expression | Nil)
      end

      def accept(visitor)
        visitor.visit_variable_statement(self)
      end

      def name
        @name
      end

      def initialiser
        @initialiser
      end
    end

    class While < Statement
      def initialize(@condition : Lox::Expression, @body : Statement)
      end

      def accept(visitor)
        visitor.visit_while_statement(self)
      end

      def condition
        @condition
      end

      def body
        @body
      end
    end
  end
end
