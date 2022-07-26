require "./interpreter.cr"
require "./statement.cr"
require "./function-type.cr"

module Lox
  # A resolver to perform static analysis on the code.
  class Resolver
    # Keep track of block scopes currently in scope.
     @scopes = Array(Hash(String, Bool)).new
     @current_function : FunctionType = FunctionType::NONE

    def initialize(@interpreter : Interpreter)
    end

    def visit_assign_expression(expression : Expression::Assign)
      resolve(expression.value)
      resolve_local(expression, expression.name)

      nil
    end

    def visit_binary_expression(expression : Expression::Binary)
      resolve(expression.left)
      resolve(expression.right)

      nil
    end

    def visit_call_expression(expression : Expression::Call)
      resolve(expression.callee)

      expression.arguments.each do |argument|
        resolve(argument)
      end
    end

    def visit_grouping_expression(expression : Expression::Grouping)
      resolve(expression.expression)

      nil
    end

    def visit_literal_expression(expression : Expression::Literal)
      nil
    end

    def visit_logical_expression(expression : Expression::Logical)
      resolve(expression.left)
      resolve(expression.right)

      nil
    end

    def visit_unary_expression(expression : Expression::Unary)
      resolve(expression.right)

      nil
    end

    # 
    def visit_variable_expression(expression : Expression::Variable)
      if !@scopes.empty? && @scopes[0][expression.name.lexeme]? == false
        Program.error(expression.name, "Can't read local variable in its own initializer.")
      end

      resolve_local(expression, expression.name)

      nil
    end

    # Create a new scope, resolve a all statements, and discard the scope.
    def visit_block_statement(statement : Statement::Block)
      begin_scope()
      resolve(statement.statements)
      end_scope()

      nil
    end

    def visit_expression_statement(statement : Statement::Expression)
      resolve(statement.expression)
      nil
    end

    def visit_function_statement(statement : Statement::Function)
      declare(statement.name)
      define(statement.name)

      resolve_function(statement, FunctionType::FUNCTION)

      nil
    end

    def visit_if_statement(statement : Statement::If)
      resolve(statement.condition)
      resolve(statement.then_branch)

      else_branch = statement.else_branch

      unless else_branch.nil?
        resolve(else_branch)
      end

      nil
    end

    def visit_print_statement(statement : Statement::Print)
      resolve(statement.expression)
      nil
    end

    def visit_return_statement(statement : Statement::Return)
      if @current_function == FunctionType::NONE
        Program.error(statement.keyword, "Can't return from top-level code.")
      end
      
      value = statement.value
        
      unless value.nil?
        resolve(value)
      end

      nil
    end

    # 
    def visit_variable_statement(statement : Statement::Variable)
      declare(statement.name)

      initialiser = statement.initialiser

      unless initialiser.nil?
        resolve(initialiser) 
      end

      define(statement.name)

      nil
    end

    def visit_while_statement(statement : Statement::While)
      resolve(statement.condition)
      resolve(statement.body)

      nil
    end

    # Push a new block scope onto the scopes stack.
    private def begin_scope
      # Crystal has no stack implementation.
      # Inner scopes are pushed onto the top of the stack.
      @scopes.insert(0, Hash(String, Bool).new)
    end

    # Add the variable to the innermost scope so that it shadows any outer
    # one and so that we know it exists.
    # Mark the variable as not ready yet, which means we've
    # not finish resolving it yet.
    private def declare(name : Token)
      if @scopes.empty?
        return
      end

      scope = @scopes[0]
      
      if scope.has_key?(name.lexeme)
        Program.error(name, "Already a variable with this name in this scope.")
      end

      scope[name.lexeme] = false
    end

    # Mark the variable as true to indicate we've finish resolving it.
    private def define(name : Token)
      if @scopes.empty?
        return
      end

      @scopes[0][name.lexeme] = true
    end

    # Remove the block scope at the top of the stack.
    private def end_scope
      @scopes.delete_at(0)
    end

    # Walk a list of statements and resolve them one by one.
    def resolve(statements : Array(Statement))
      statements.each do |statement|
        resolve(statement)
      end
    end

    # Similar to evaluate and execute methods in the interpreter.
    # Apply the Visitor pattern to the given AST.
    private def resolve(statement : Statement)
      statement.accept(self)
    end

    # Similar to evaluate and execute methods in the interpreter.
    # Apply the Visitor pattern to the given AST.
    private def resolve(expression : Expression)
      expression.accept(self)
    end

    private def resolve_function(function : Statement::Function, type : FunctionType)
      enclosing_function = @current_function
      @current_function = type
      
      begin_scope()

      function.parameters.each do |parameter|
        declare(parameter)
        define(parameter)
      end

      resolve(function.body)

      end_scope()
    end

    # Start from the innermost scope and work outwards, looking
    # at each scope to find the variable.
    def resolve_local(expression : Expression, name : Token)
      # Unlike the Java implementation, the innermost scope starts at index 0.
      i = 0

      while i <= @scopes.size - 1
        if @scopes[i].has_key?(name.lexeme)
          @interpreter.resolve(expression, i)
          return
        end

        i += 1
      end
    end
  end
end
