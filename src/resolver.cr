require "./interpreter.cr"
require "./statement.cr"

module Lox
  @scopes = Array(Hash(String, Bool))

  def initialize(@interpreter : Interpreter)
  end

  def visit_assign_expression(statement : Statement::Assign)
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
    
    resolve_function(statement)

    nil
  end

  def visit_if_statement(statement : Statement::If)
    resolve(statement.condition)
    resolve(statement.thenBranch)

    if !statement.elseBranch.nil?
      resolve(statement.elseBranch)
    end
  end

  def visit_print_statement(statement : Statement::Print)
    resolve(statement.expression)
  end

  def visit_return_statement(statement : Statement::Return)
    if !statement.nil?
      resolve(statement.value)
    end
    
      nil
  end

  def visit_while_statement(statement : Statement::While)
    resolve(statement.condition)
    resolve(statement.body)

    nil
  end

  def visit_var_statement(statement : Statement::Variable)
    declare(statement.name)

    unless statement.initaliser.nil?
      resolve(statement.initaliser)
    end

    define(statement.name)

    nil
  end


  def visit_var_expression(expression : Expression::Variable)
    if scopes.empty? && !scopes.last[expression.name.lexeme]
      Program.error(expression.name, "Can't read local variable in its own initializer.")
    end

    resolve_local(expression, expression.name)

    nil
  end

  def resolve_local(expression : Expression, name : Token)
    i = 0

    while i < @scopes.size
      if @scopes[i].first_key?(name.lexeme)
        @interpreter.resolve(expression, i)
        
        break
      end

      i += 1
    end
  end

  private def define(name : Token)
    if scopes.empty?
      return
    end

    scopes
  end

  private def declare(name : Token)
    if scopes.empty?
      return
    end

    scope = scopes.last?
    scope[name.lexeme] = false
  end

  private def begin_scope
    scopes << Hash(String, Bool).new
  end

  private def end_scope
    scopes.pop
  end

  private def resolve(statements : Array(Statement))
    statements.each do |statement|
      resolve(statement)
    end
  end

  private def resolve(statement : Statement)
    statement.accept(self)
  end

  private def resolve(expression : Expression)
    expression.accept(self)
  end

  private def resolve_function(function : Statement::Function)
    begin_scope()

    function.params.each do |param|
      declare(param)
      define(param)
    end

    resolve(function.body)
    end_scope()
  end
end
