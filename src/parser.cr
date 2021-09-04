require "../src/main.cr"
require "../src/parse-exception.cr"

class Parser
  # Expression grammar:
  # expression     → equality ;
  # equality       → comparison ( ( "!=" | "==" ) comparison )* ;
  # comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  # term           → factor ( ( "-" | "+" ) factor )* ;
  # factor         → unary ( ( "/" | "*" ) unary )* ;
  # unary          → ( "!" | "-" ) unary | primary ;
  # primary        → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" ;

  @tokens : Array(Token) = Array(Token).new
  @current : Int32 = 0

  def initialize(tokens : Array(Token))
    @tokens = tokens
  end

  #   private def expression : Expression
  #     equality()
  #   end

  #   private def equality : Expression
  #     expression = comparison()

  #     while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
  #       operator = previous()
  #       right = comparison()
  #       expression = Expression.Binary(expression, operator, right)
  #     end

  #     expression
  #   end

  #   private def comparison : Expression
  #     expression = term()

  #     while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
  #       operator = previous()
  #       right = term()
  #       expression = Expression.Binary(expression, operator, right)
  #     end

  #     expression
  #   end

  #   private def term : Expression
  #     expression = factor()

  #     while match(TokenType::MINUS, TokenType::PLUS)
  #       operator = previous()
  #       right = factor()
  #       expression = Expression.Binary(expression, operator, right)
  #     end

  #     expression
  #   end

  #   private def factor : Expression
  #     expression = unary()

  #     while match(TokenType::SLASH, TokenType::STAR)
  #       operator = previous()
  #       right = factor()
  #       expression = Expression.Binary(expression, operator, right)
  #     end

  #     expression
  #   end

  #   private def unary : Expression
  #     if match(TokenType::SLASH, TokenType::STAR)
  #       operator = previous()
  #       right = unary()
  #       return Expression.Unary(expression, operator, right)
  #     end

  #     primary()
  #   end

  #   private def primary : Expression
  #     if match(TokenType::FALSE)
  #       return Expression.Literal(false)
  #     end

  #     if match(TokenType::TRUE)
  #       return Expression.Literal(true)
  #     end

  #     if match(TokenType::NIL)
  #       return Expression.Literal(nil)
  #     end

  #     if match(TokenType::NUMBER, TokenType::STRING)
  #       return Expression.Literal(previous().literal)
  #     end

  #     if match(TokenType::LEFT_PAREN)
  #       expression = expression()
  #       consume(TokenType::RIGHT_PAREN, "Expect ')' after expression.")
  #       return Expression.Grouping(expression)
  #     end

  #     nil
  #   end

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

    error(peek(), message)
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
    (Program.new).error(token, message)
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
