require "../src/main.cr"
require "../src/parse-exception.cr"
require "../src/expression.cr"
require "../src/statement.cr"

class Parser
  # Expression grammar:
  # expression     → equality ;
  # equality       → comparison ( ( "!=" | "==" ) comparison )* ;
  # comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  # term           → factor ( ( "-" | "+" ) factor )* ;
  # factor         → unary ( ( "/" | "*" ) unary )* ;
  # unary          → ( "!" | "-" ) unary | primary ;
  # primary        → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER ;

  # Parser grammar:
  # program        → declaration* EOF ;
  # declaration    → varDecl | statement ;
  # statement      → exprStmt | printStmt ;
  # exprStmt       → expression ";" ;
  # printStmt      → "print" expression ";" ;
  # varDecl        → "var" IDENTIFIER ( "=" expression )? ";" ;

  def initialize(@tokens : Array(Token), @current : Int32 = 0)
  end

  # Parse a series of statements until the end.
  def parse : Array(Statement)
    statements = Array(Statement).new

    while !is_at_end()
      statements << declaration()
    end

    statements
  end

  # Rule: statement → exprStmt | printStmt ;
  private def statement : Statement
    if match(TokenType::PRINT)
      return print_statement()
    end

    expression_statement()
  end

  # Rule: printStmt → "print" expression ";" ;
  private def print_statement : Statement
    value = expression()
    consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Print.new(value)
  end

  # Rule: varDecl → "var" IDENTIFIER ( "=" expression )? ";" ;
  private def var_declaration : Statement
    name = consume(TokenType::IDENTIFIER, "Expect variable name.")
    initialiser = nil;
    
    if match(TokenType::EQUAL)
      initialiser = expression()
    end

    consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
    Variable.new(name, initialiser);
  end

  # Rule: exprStmt → expression ";" ;
  private def expression_statement : Statement
    expression = expression()
    consume(TokenType::SEMICOLON, "Expect ';' after expression.")
    ExpressionStatement.new(expression)
  end

  # Rule: expression → equality ;
  private def expression : Expression
    equality()
  end

  # Rule:declaration → varDecl | statement ;
  private def declaration : Expression
    begin
      if match(TokenType::VAR)
        return var_declaration()
      end
    rescue ParseException
      # When we run into an error, skip to the start
      # of the next statement or declaration.
      synchronise()
    end
  end

  # Rule: equality → comparison ( ( "!=" | "==" ) comparison )* ;
  private def equality : Expression
    expression = comparison()

    while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      operator = previous()
      right = comparison()
      expression = Binary.new(expression, operator, right)
    end

    expression
  end

  # Rule: comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  private def comparison : Expression
    expression = term()

    while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      operator = previous()
      right = term()
      expression = Binary.new(expression, operator, right)
    end

    expression
  end

  # Rule: term → factor ( ( "-" | "+" ) factor )* ;
  private def term : Expression
    expression = factor()

    while match(TokenType::MINUS, TokenType::PLUS)
      operator = previous()
      right = factor()
      expression = Binary.new(expression, operator, right)
    end

    expression
  end

  # Rule: factor → unary ( ( "/" | "*" ) unary )* ;
  private def factor : Expression
    expression = unary()

    while match(TokenType::SLASH, TokenType::STAR)
      operator = previous()
      right = factor()
      expression = Binary.new(expression, operator, right)
    end

    expression
  end

  # Rule: unary → ( "!" | "-" ) unary | primary ;
  private def unary : Expression
    if match(TokenType::BANG, TokenType::MINUS)
      operator = previous()
      right = unary()
      return Unary.new(operator, right)
    end

    primary()
  end

  # Rule: primary → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER;
  private def primary : Expression
    if match(TokenType::FALSE)
      return Literal.new(false)
    end

    if match(TokenType::TRUE)
      return Literal.new(true)
    end

    if match(TokenType::NIL)
      return Literal.new(nil)
    end

    if match(TokenType::NUMBER, TokenType::STRING)
      return Literal.new(previous().literal)
    end

    if match(TokenType::IDENTIFIER)
      return Variable.new(previous())
    end 

    if match(TokenType::LEFT_PAREN)
      expression = expression()
      consume(TokenType::RIGHT_PAREN, "Expect ')' after ")
      return Grouping.new(expression)
    end

    raise "Unexpected token '#{peek().lexeme}'!"
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
    if !is_at_end()
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
  private def error(token : Token, message : String) : ParseException
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
