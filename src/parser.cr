require "./main.cr"
require "./parse-exception.cr"
require "./expression.cr"
require "./statement.cr"

module Lox
  class Parser
    # Expression grammar:
    # expression     → assigment ;
    # assignment     → ( call "." )? IDENTIFIER "=" assignment | logic_or ;
    # logic_or       → logic_and ( "or" logic_and )* ;
    # logic_and      → equality ( "and" equality )* ;
    # equality       → comparison ( ( "!=" | "==" ) comparison )* ;
    # comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
    # term           → factor ( ( "-" | "+" ) factor )* ;
    # factor         → unary ( ( "/" | "*" ) unary )* ;
    # unary          → ( "!" | "-" ) unary | call ;
    # call           → primary ( "(" arguments? ")" | "." IDENTIFIER )* ;
    # arguments      → expression ( "," expression )* ;
    # primary        → "true" | "false" | "nil" | "this" | NUMBER | STRING | IDENTIFIER | "(" expression ")" | "super" "." IDENTIFIER ;

    # Parser grammar:
    # program        → declaration* EOF ;
    # declaration    → classDecl | funDecl | varDecl | statement ;
    # classDecl      → class" IDENTIFIER ( "<" IDENTIFIER )? "{" function* "}" ;
    # funDecl        → "fun" function ;
    # function       → IDENTIFIER "(" parameters? ")" block ;
    # parameters     → IDENTIFIER ( "," IDENTIFIER )* ;
    # varDecl        → "var" IDENTIFIER ( "=" expression )? ";" ;
    # statement      → exprStmt | forStmt | ifStmt | printStmt | returnStmt | whileStmt | block ;
    # exprStmt       → expression ";" ;
    # forStmt        → "for" "(" ( varDecl | exprStmt | ";" ) expression? ";" expression? ")" statement ;
    # ifStmt         → "if" "(" expression ")" statement ( "else" statement )? ;
    # printStmt      → "print" expression ";" ;
    # returnStmt     → "return" expression? ";" ;
    # whileStmt      → "while" "(" expression ")" statement ;
    # block          → "{" declaration* "}" ;

    def initialize(@tokens : Array(Token), @current : Int32 = 0)
    end

    # Parse a series of statements until the end.
    def parse : Array(Statement)
      statements = Array(Statement).new

      while !is_at_end()
        decl = declaration()
        statements << decl.as(Statement) unless decl.nil?
      end

      statements
    end

    # Rule: statement → exprStmt | forStmt | ifStmt | printStmt | returnStmt | whileStmt | block ;
    private def statement : Statement
      if match(TokenType::IF)
        return if_statement()
      end

      if match(TokenType::FOR)
        return for_statement()
      end

      if match(TokenType::PRINT)
        return print_statement()
      end

      if match(TokenType::RETURN)
        return return_statement()
      end

      if match(TokenType::WHILE)
        return while_statement()
      end

      if match(TokenType::LEFT_BRACE)
        return Statement::Block.new(block_statement())
      end

      expression_statement()
    end

    # Rule: ifStmt → "if" "(" expression ")" statement ( "else" statement )? ;
    private def if_statement : Statement
      consume(TokenType::LEFT_PAREN, "Expect '(' after 'if'.")

      condition = expression()

      consume(TokenType::RIGHT_PAREN, "Expect ')' after if condition.")

      then_branch = statement()
      else_branch = nil

      if match(TokenType::ELSE)
        else_branch = statement()
      end

      Statement::If.new(condition, then_branch, else_branch)
    end

    # Rule: forStmt → "for" "(" ( varDecl | exprStmt | ";" ) expression? ";" expression? ")" statement ;
    private def for_statement : Statement
      consume(TokenType::LEFT_PAREN, "Expect '(' after 'for'.")

      initialiser = nil

      if match(TokenType::SEMICOLON)
        initialiser = nil
      elsif match(TokenType::VAR)
        initialiser = var_declaration()
      else
        initialiser = expression_statement()
      end

      condition = nil

      unless check(TokenType::SEMICOLON)
        condition = expression()
      end

      consume(TokenType::SEMICOLON, "Expect ';' after loop condition.")

      increment = nil

      unless check(TokenType::RIGHT_PAREN)
        increment = expression()
      end

      consume(TokenType::RIGHT_PAREN, "Expect ')' after for clauses.")

      body = statement()

      unless increment.nil?
        statements = [body, Statement::Expression.new(increment)]
        body = Statement::Block.new(statements)
      end

      if condition.nil?
        condition = Expression::Literal.new(true)
      end

      body = Statement::While.new(condition, body)

      unless initialiser.nil?
        statements = [initialiser, body]
        body = Statement::Block.new(statements)
      end

      body
    end

    # Rule: printStmt → "print" expression ";" ;
    private def print_statement : Statement
      value = expression()

      consume(TokenType::SEMICOLON, "Expect ';' after value.")

      Statement::Print.new(value)
    end

    # Rule: returnStmt → "return" expression? ";" ;
    private def return_statement : Statement
      keyword = previous()
      value = nil

      unless check(TokenType::SEMICOLON)
        value = expression()
      end

      consume(TokenType::SEMICOLON, "Expect ';' after return value.")

      Statement::Return.new(keyword, value)
    end

    # Rule: function → IDENTIFIER "(" parameters? ")" block ;
    private def function(kind : String) : Statement
      name = consume(TokenType::IDENTIFIER, "Expect #{kind} name.")

      consume(TokenType::LEFT_PAREN, "Expect '(' after #{kind} name.")

      parameters = Array(Token).new

      unless check(TokenType::RIGHT_PAREN)
        loop do
          if parameters.size >= 255
            error(peek(), "Can't have more than 255 parameters.")
          end

          parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")

          break unless match(TokenType::COMMA)
        end
      end

      consume(TokenType::RIGHT_PAREN, "Expect ')' after parameters.")

      consume(TokenType::LEFT_BRACE, "Expect '{' before #{kind} body.")

      body = block_statement()

      Statement::Function.new(name, parameters, body)
    end

    # Rule: varDecl → "var" IDENTIFIER ( "=" expression )? ";" ;
    private def var_declaration : Statement
      name = consume(TokenType::IDENTIFIER, "Expect variable name.")
      initialiser = nil
      if match(TokenType::EQUAL)
        initialiser = expression()
      end

      consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
      Statement::Variable.new(name, initialiser)
    end

    # Rule: whileStmt → "while" "(" expression ")" statement ;
    private def while_statement : Statement
      consume(TokenType::LEFT_PAREN, "Expect '(' after 'while'.")

      condition = expression()

      consume(TokenType::RIGHT_PAREN, "Expect ')' after condition.")

      body = statement()

      Statement::While.new(condition, body)
    end

    # Rule: exprStmt → expression ";" ;
    private def expression_statement : Statement
      expression = expression()
      consume(TokenType::SEMICOLON, "Expect ';' after expression.")
      Statement::Expression.new(expression)
    end

    # Rule: block → "{" declaration* "}" ;
    def block_statement : Array(Statement)
      statements = Array(Statement).new

      while !check(TokenType::RIGHT_BRACE) && !is_at_end()
        decl = declaration()
        statements << decl unless decl.nil?
      end

      consume(TokenType::RIGHT_BRACE, "Expect '}' after block.")

      statements
    end

    # Rule: declaration → classDecl | funDecl | varDecl | statement ;
    private def declaration : Statement | Nil
      begin
        if match(TokenType::CLASS)
          return class_declaration()
        end

        if match(TokenType::FUN)
          return function("function")
        end

        if match(TokenType::VAR)
          return var_declaration()
        end

        return statement()
      rescue ParseException
        # When we run into an error, skip to the start
        # of the next statement or declaration.
        synchronise()

        return nil
      end
    end

    # Rule: classDecl → "class" IDENTIFIER ( "<" IDENTIFIER )? "{" function* "}" ;
    private def class_declaration : Statement
      name = consume(TokenType::IDENTIFIER, "Expect class name.")

      superClass = nil

      if match(TokenType::LESS)
        consume(TokenType::IDENTIFIER, "Expect superclass name.")
        superClass = Expression::Variable.new(previous())
      end

      consume(TokenType::LEFT_BRACE, "Expect '{' before class body.")

      methods = Array(Statement::Function).new

      while !check(TokenType::RIGHT_BRACE) && !is_at_end()
        methods << function("method")
      end

      consume(TokenType::RIGHT_BRACE, "Expect '}' after class body.")

      Statement::Class.new(name, superClass, methods)
    end

    # Rule: expression → assigment ;
    private def expression : Expression
      assignment()
    end

    # Rule: assignment → IDENTIFIER "=" assignment | logic_or ;
    private def assignment : Expression
      expression = or()

      if match(TokenType::EQUAL)
        equals = previous()
        value = assignment()

        if expression.is_a?(Expression::Variable)
          name = expression.as(Expression::Variable).name
          return Expression::Assign.new(name, value)
        elsif expression.is_a?(Expression::Get)
          get = expression.as(Expression::Get)
          return Expression::Set.new(get.object, get.name, value)
        end

        error(equals, "Invalid assignment target.")
      end

      expression
    end

    # Rule: logic_or → logic_and ( "or" logic_and )* ;
    private def or : Expression
      expression = and()

      while match(TokenType::OR)
        operator = previous()
        right = and()

        expression = Expression::Logical.new(expression, operator, right)
      end

      expression
    end

    # Rule: logic_and → equality ( "and" equality )* ;
    private def and : Expression
      expression = equality()

      while match(TokenType::AND)
        operator = previous()
        right = equality()

        expression = Expression::Logical.new(expression, operator, right)
      end

      expression
    end

    # Rule: equality → comparison ( ( "!=" | "==" ) comparison )* ;
    private def equality : Expression
      expression = comparison()

      while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
        operator = previous()
        right = comparison()
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    # Rule: comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
    private def comparison : Expression
      expression = term()

      while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
        operator = previous()
        right = term()
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    # Rule: term → factor ( ( "-" | "+" ) factor )* ;
    private def term : Expression
      expression = factor()

      while match(TokenType::MINUS, TokenType::PLUS)
        operator = previous()
        right = factor()
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    # Rule: factor → unary ( ( "/" | "*" ) unary )* ;
    private def factor : Expression
      expression = unary()

      while match(TokenType::SLASH, TokenType::STAR)
        operator = previous()
        right = unary()
        expression = Expression::Binary.new(expression, operator, right)
      end

      expression
    end

    # Rule: unary → ( "!" | "-" ) unary | call ;
    private def unary : Expression
      if match(TokenType::BANG, TokenType::MINUS)
        operator = previous()
        right = unary()
        return Expression::Unary.new(operator, right)
      end

      call()
    end

    # Rule: call → primary ( "(" arguments? ")" | "." IDENTIFIER )* ;
    private def call
      expression = primary()

      while true
        if match(TokenType::LEFT_PAREN)
          expression = finish_call(expression)
        elsif match(TokenType::DOT)
          name = consume(TokenType::IDENTIFIER, "Expect property name after '.'.")
          expression = Expression::Get.new(expression, name)
        else
          break
        end
      end

      expression
    end

    # Parse the arguments of the call expression and
    # wrap the callee and arguments together into an
    # AST node.
    private def finish_call(callee : Expression)
      arguments = Array(Expression).new

      if !check(TokenType::RIGHT_PAREN)
        loop do
          if arguments.size >= 255
            error(peek(), "Can't have more than 255 arguments.")
          end

          arguments << expression()

          break unless match(TokenType::COMMA)
        end
      end

      paren = consume(TokenType::RIGHT_PAREN, "Expect ')' after arguments.")

      Expression::Call.new(callee, paren, arguments)
    end

    # Rule: primary → NUMBER | STRING | "true" | "false" | "nil" | "this" | "(" expression ")" | IDENTIFIER;
    private def primary : Expression
      # puts "primary"

      if match(TokenType::FALSE)
        return Expression::Literal.new(false)
      end

      if match(TokenType::TRUE)
        return Expression::Literal.new(true)
      end

      if match(TokenType::NIL)
        return Expression::Literal.new(nil)
      end

      if match(TokenType::SUPER)
        keyword = previous()

        consume(TokenType::DOT, "Expect '.' after 'super'.")

        method = consume(TokenType::IDENTIFIER, "Expect superclass method name.")

        return Expression::Super.new(keyword, method)
      end

      if match(TokenType::NUMBER, TokenType::STRING)
        return Expression::Literal.new(previous().literal)
      end

      if match(TokenType::THIS)
        return Expression::This.new(previous())
      end

      if match(TokenType::IDENTIFIER)
        return Expression::Variable.new(previous())
      end

      if match(TokenType::LEFT_PAREN)
        expression = expression()
        consume(TokenType::RIGHT_PAREN, "Expect ')' after ")
        return Expression::Grouping.new(expression)
      end

      raise error(peek(), "Expect expression.")
    end

    # Check if the current token has any of the given types.
    # If so, consume it and return true, else false.
    private def match(*types : TokenType) : Bool
      types.each do |type|
        if check(type)
          advance()
          return true
        end
      end

      false
    end

    # Consume the current token only if the token type matches
    # provided type, otherwise raise a parse error.
    private def consume(type : TokenType, message : String) : Token
      if check(type)
        return advance()
      end

      # Can we bubble up errors like in Java?
      raise error(peek(), message)
    end

    # Check if the current token is a given type.
    # This does not consume the token.
    private def check(type : TokenType) : Bool
      if is_at_end()
        return false
      end

      peek().type == type
    end

    # Consume the current token and return it.
    private def advance : Token
      unless is_at_end()
        @current += 1
      end

      previous()
    end

    # Check if we are at the end of list of tokens to parse.
    private def is_at_end : Bool
      peek().type == TokenType::EOF
    end

    # Return the current token without consuming it.
    private def peek : Token
      @tokens[@current]
    end

    # Return the most recent consumed token.
    private def previous : Token
      @tokens[@current - 1]
    end

    # Report a parse error.
    private def error(token : Token, message : String)
      # Not sure if this will call a static function with
      # the same state and behaviour as in Java or C#.
      Program.error(token, message)
      ParseException.new
    end

    # When we raise a parse error, we might be still in the statement that
    # cause the error. Thus we need to consume tokens until we reach the
    # start of the next statement.
    private def synchronise
      advance()

      # Keep consuming tokens until we reach the beginnings of the next statement.
      while !is_at_end()
        # A statement begins after a semicolon (usually).
        if previous().type == TokenType::SEMICOLON
          return
        end

        # Most statements are with a keyword, so when we reach keyword, we should stop the
        # synchronisation.
        case peek().type
        when TokenType::CLASS, TokenType::FUN, TokenType::VAR, TokenType::FOR, TokenType::IF, TokenType::WHILE, TokenType::PRINT, TokenType::RETURN
          return
        end

        advance()
      end
    end
  end
end
