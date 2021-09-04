require "../src/main.cr"
require "../src/token-type.cr"
require "../src/token.cr"

class Scanner
  @source : String = ""
  @tokens : Array(Token) = Array(Token).new
  @start : Int32 = 0   # Offset of the first character of the lexeme being scanned.
  @current : Int32 = 0 # Offset of the current character being scanned.
  @line : Int32 = 1    # Track the line of the current character is on.
  @@keywords : Hash(String, TokenType) = {
    "and"    => TokenType::AND,
    "class"  => TokenType::CLASS,
    "else"   => TokenType::ELSE,
    "false"  => TokenType::FALSE,
    "for"    => TokenType::FOR,
    "fun"    => TokenType::FUN,
    "if"     => TokenType::IF,
    "nil"    => TokenType::NIL,
    "or"     => TokenType::OR,
    "print"  => TokenType::PRINT,
    "return" => TokenType::RETURN,
    "super"  => TokenType::SUPER,
    "this"   => TokenType::THIS,
    "true"   => TokenType::TRUE,
    "var"    => TokenType::VAR,
    "while"  => TokenType::WHILE,
  }

  def initialize(source : String)
    @source = source
  end

  # Work through the source code adding tokens until you
  # run out of characters.
  def scan_tokens : Array(Token)
    while !is_at_end()
      # Currently at the start of the next lexeme.
      @start = @current
      scan_token()
    end

    # Add EOF token at the end to make our parser cleaner.
    @tokens << Token.new(TokenType::EOF, "", "", @line, true)
    @tokens
  end

  # Try to match a lexeme to create a new token so that
  # it can be added to tokens.
  private def scan_token
    c : Char = advance()

    case c
    when '('
      add_token(TokenType::LEFT_PAREN)
    when ')'
      add_token(TokenType::RIGHT_PAREN)
    when '{'
      add_token(TokenType::LEFT_BRACE)
    when '}'
      add_token(TokenType::RIGHT_BRACE)
    when ','
      add_token(TokenType::COMMA)
    when '.'
      add_token(TokenType::DOT)
    when '-'
      add_token(TokenType::MINUS)
    when '+'
      add_token(TokenType::PLUS)
    when ';'
      add_token(TokenType::SEMICOLON)
    when '*'
      add_token(TokenType::STAR)
    when '!'
      add_token(match('=') ? TokenType::BANG_EQUAL : TokenType::BANG)
    when '='
      add_token(match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
    when '<'
      add_token(match('=') ? TokenType::LESS_EQUAL : TokenType::LESS)
    when '>'
      add_token(match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER)
    when '/'
      if match('/')
        # A comment goes until the end of the line./
        while peek() != '\n' && !is_at_end()
          advance()
        end
      else
        add_token(TokenType::SLASH)
      end
    when ' ', '\r', '\t'
      # Ignore whitespace. Do nothing.
    when '\n'
      @line += 1
    when '"'
      string()
    when 'o'
      if match('r')
        add_token(TokenType::OR)
      end
    else
      if is_digit(c)
        number()
      elsif is_alpha(c)
        identifier()
      else
        Program.error(@line, "Unexpected character.")
      end
    end
  end

  # Consume the entire identifier literal.
  private def identifier
    while is_alpha_numeric(peek())
      advance()
    end

    text : String = @source[@start..(@current - 1)]
    type : TokenType | Nil = @@keywords[text]?
    if type.nil?
      type = TokenType::IDENTIFIER
    end

    add_token(type)
  end

  # Consume the entire string literal.
  private def string
    while peek() != '"' && !is_at_end()
      if peek() == '\n'
        @line += 1
      end

      advance()
    end

    if is_at_end()
      Program.error(@line, "Unterminated string.")
      return
    end

    # Consume the closing '"'.
    advance()

    # Trim the surounding quotes.
    value : String = @source[(@start + 1)..(@current - 2)]
    add_token(TokenType::STRING, value)
  end

  # Consume the number literal, which can be an natural or decimal number.
  private def number
    # Consume the whole number part.
    while is_digit(peek())
      advance()
    end

    # Look for the decimal dot and consume it.
    if peek() == '.' && is_digit(peek_next())
      # Consume the '.'.
      advance()
    end

    # Consume the fractional part.
    while is_digit(peek())
      advance()
    end

    add_token(TokenType::NUMBER, @source[@start..(@current - 1)].to_f64)
  end

  # Only consume the current character if it's the one we're expecting.
  private def match(expected : Char) : Bool
    if is_at_end()
      return false
    end

    if @source[@current] != expected
      return false
    end

    @current += 1

    true
  end

  # Look ahead at the current character and return it.
  # This does not consume the character.
  private def peek : Char
    if is_at_end()
      return '\0'
    end

    @source[@current]
  end

  # Look ahead at the next character and return it.
  # This does not consume the character.
  private def peek_next : Char
    if @current + 1 >= @source.size
      return '\0'
    end

    @source[@current + 1]
  end

  # Check if the character is an alpha including an underscore.
  private def is_alpha(c : Char) : Bool
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  end

  # Check if the character is an alpha numeric including an underscore.
  private def is_alpha_numeric(c : Char) : Bool
    is_alpha(c) || is_digit(c)
  end

  # Check if the character is between the digits 0 and 9.
  private def is_digit(c : Char) : Bool
    c >= '0' && c <= '9'
  end

  # Check to see if we consumed all of the characters.
  private def is_at_end : Bool
    @current >= @source.size
  end

  # Consume the next character and return it.
  private def advance : Char
    c : Char = @source[@current]
    # Currently there is no post increment operators.
    @current += 1
    c
  end

  # Take the lexeme literal to create a new token from it and
  # add it to tokens.
  private def add_token(type : TokenType, null : Bool = false)
    add_token(type, "", true)
  end

  # Take the lexeme literal to create a new token from it and
  # add it to tokens.
  private def add_token(type : TokenType, literal : Object, null : Bool = false)
    text : String = @source[@start..(@current - 1)]
    @tokens << Token.new(type, text, literal, @line, null)
  end
end
