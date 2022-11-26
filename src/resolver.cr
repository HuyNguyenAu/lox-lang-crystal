require "./interpreter.cr"
require "./statement.cr"
require "./function-type.cr"
require "./class-type.cr"

module Lox
  # A resolver class to perform static analysis.
  class Resolver
    # Keep track of block scopes currently in scope.
    @scopes = Array(Hash(String, Bool)).new
    # Keep track of return statements and make sure it's not used outside of functions.
    @current_function : FunctionType = FunctionType::NONE
    # Keep track of 'this' and make sure it's not used outside of methods.
    @current_class : ClassType = ClassType::NONE

    def initialize(@interpreter : Interpreter)
    end

    # Resolve the assignement expression.
    def visit_assign_expression(expression : Expression::Assign)
      # Resolve the expression for the assigned value in case it contains
      # references to other variables.
      resolve(expression.value)
      # Resolve the variable that's being assigned to.
      resolve_local(expression, expression.name)

      nil
    end

    # Resolve the binary expression.
    def visit_binary_expression(expression : Expression::Binary)
      # Resolve both operands.
      resolve(expression.left)
      resolve(expression.right)

      nil
    end

    # Resolve the call expression.
    def visit_call_expression(expression : Expression::Call)
      # The callee is usually an expression, so it should be resolved as well.
      resolve(expression.callee)

      # Walk the argument list and resolve them all.
      expression.arguments.each do |argument|
        resolve(argument)
      end
    end

    # Resolve the get expression. The property is dynamically evaulated, so
    # there's nothing to resolve here.
    def visit_get_expression(expression : Expression::Get)
      # Resolve the expresssion to the left of the dot.
      resolve(expression.object)
      nil
    end

    # Resolve the grouping expression.
    def visit_grouping_expression(expression : Expression::Grouping)
      # Resolve the expression inside the parenthesis.
      resolve(expression.expression)

      nil
    end

    # Resolve the literal expression.
    def visit_literal_expression(expression : Expression::Literal)
      # Nothing to do here since there's no expression or variables.
      nil
    end

    # Resolve the logical expression.
    def visit_logical_expression(expression : Expression::Logical)
      # Resolve the left and right expressions.
      resolve(expression.left)
      resolve(expression.right)

      nil
    end

    # Resolve the set expression. The property is dynamically evaulated, so
    # there's nothing to resolve here.
    def visit_set_expression(expression : Expression::Set)
      resolve(expression.value)
      resolve(expression.object)

      nil
    end

    # Resolve the super expression exactly as a variable.
    # Find the environment where the super class is stored and
    # store the number of hops to that environment.
    def visit_super_expression(expression : Expression::Super)
      # Make sure super is only inside a sub class.
      if @current_class == ClassType::NONE
        Program.error(expression.keyword, "Can't use 'super' outside of a class.")
      elsif @current_class != ClassType::SUBCLASS
        Program.error(expression.keyword, "Can't use 'super' in a class with no superclass.")
      end

      resolve_local(expression, expression.keyword)

      nil
    end

    # Resolve the unary expression.
    def visit_unary_expression(expression : Expression::Unary)
      # Resolve its one operand.
      resolve(expression.right)

      nil
    end

    # Resolve the variable expression.
    def visit_variable_expression(expression : Expression::Variable)
      # Check if the variable is being accessed inside its own initialiser.
      if !@scopes.empty? && @scopes[0][expression.name.lexeme]? == false
        Program.error(expression.name, "Can't read local variable in its own initializer.")
      end

      # Resolve the variable.
      resolve_local(expression, expression.name)

      nil
    end

    # Resolve as a variable with the name 'this'.
    def visit_this_expression(expression : Expression::This)
      # Don't allow the 'this' expression outside of a class.
      if @current_class == ClassType::NONE
        Program.error(expression.keyword, "Can't use 'this' outside of a class.")

        return nil
      end

      resolve_local(expression, expression.keyword)

      nil
    end

    # Resolve the block statement.
    def visit_block_statement(statement : Statement::Block)
      # Create a new scope, resolve a all statements, and discard the scope.
      begin_scope()
      resolve(statement.statements)
      end_scope()

      nil
    end

    # Resolve the class statement.
    def visit_class_statement(statement : Statement::Class)
      # Keep track of the previous class so that we don't lose track
      # of it in nested classes.
      enclosing_class = @current_class
      @current_class = ClassType::CLASS

      # Define and declare the name of the function in the current scope.
      declare(statement.name)
      define(statement.name)

      # Currently, Crystal's compiler is unable to figure out if a variable is not a
      # nil after a nil check.
      superClass = statement.superClass

      # Make sure the super class in not the same as the class name.
      unless superClass.nil?
        if statement.name.lexeme == superClass.name.lexeme
          Program.error(superClass.name, "A class can't inherit from itself.")
        end

        # The super class name will most likely be a global variable since classes are
        # declared usually at the top level. A super class can be a local variable since
        # class declarations are allowed in block statements.
        @current_class = ClassType::SUBCLASS
        resolve(superClass)

        # Create a new scope surrounding all it's methods.
        begin_scope()
        @scopes[0]["super"] = true
      end

      # Before we start resolving the method bodies, we push a new scope and
      # define 'this' as if it was a variable.
      begin_scope()
      @scopes[0]["this"] = true

      # Resolve each method.
      # If we run into a 'this', it will be resolved into local variable which
      # is located just outside the method body.
      statement.methods.each() do |method|
        declaration = FunctionType::METHOD

        # Keep track of when we are resolving a initialiser so that we can
        # disallow return statements in the initialiser.
        if method.name.lexeme == "init"
          declaration = FunctionType::INITIALISER
        end

        resolve_function(method, declaration)
      end

      end_scope()

      # Disard the scope that surrounds all the methods.
      unless statement.superClass.nil?
        end_scope()
      end

      @current_class = enclosing_class

      nil
    end

    # Resolve the expression statement.
    def visit_expression_statement(statement : Statement::Expression)
      # Only contains a single statement to resolve.
      resolve(statement.expression)
      nil
    end

    # Resolve the function statement.
    def visit_function_statement(statement : Statement::Function)
      # Define and declare the name of the function in the current scope.
      declare(statement.name)
      define(statement.name)
      # Resolve the function's body.
      resolve_function(statement, FunctionType::FUNCTION)

      nil
    end

    # Resolve the if statement.
    def visit_if_statement(statement : Statement::If)
      # Resolve the expressions for the condition and then statements.
      resolve(statement.condition)
      resolve(statement.then_branch)

      # If there is an else statement, then resolve.
      else_branch = statement.else_branch

      unless else_branch.nil?
        resolve(else_branch)
      end

      nil
    end

    # Resolve the print statement.
    def visit_print_statement(statement : Statement::Print)
      # Resolve the single subexpression.
      resolve(statement.expression)
      nil
    end

    # Resolve the return statement.
    def visit_return_statement(statement : Statement::Return)
      if @current_function == FunctionType::NONE
        Program.error(statement.keyword, "Can't return from top-level code.")
      end

      # Only resolve return expression if present.
      value = statement.value

      unless value.nil?
        # Don't allow return statements in initialiser.
        if @current_function == FunctionType::INITIALISER
          Program.error(statement.keyword, "Can't return a value from an initialiser.")
        end

        resolve(value)
      end

      nil
    end

    # Resolve the variable statement.
    def visit_variable_statement(statement : Statement::Variable)
      declare(statement.name)

      initialiser = statement.initialiser

      unless initialiser.nil?
        resolve(initialiser)
      end

      define(statement.name)

      nil
    end

    # Resolve the while statement.
    def visit_while_statement(statement : Statement::While)
      # Resolve the condition and body expression.
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

    # Resolve a function's body.
    private def resolve_function(function : Statement::Function, type : FunctionType)
      enclosing_function = @current_function
      @current_function = type

      # Create a new scope for the body.
      begin_scope()

      # Bind variables for each of the function's parameters.
      function.parameters.each do |parameter|
        declare(parameter)
        define(parameter)
      end

      # Resolve the function's body in the current scope.
      resolve(function.body)

      # Discard the function's body scope.
      end_scope()
    end

    # Try to resolve a variable by looking at each scope, from the innermost to the outermost.
    def resolve_local(expression : Expression, name : Token)
      # Unlike the Java implementation, the innermost scope starts at index 0.
      i = 0

      # Start from the innermost scope and work outwards, looking
      # at each scope to find the variable.
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
