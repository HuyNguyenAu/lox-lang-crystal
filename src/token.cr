require "../src/token-type.cr"

class Token
  # Used to pass tests since Crystal does not support nil like Java's null.
  # When you print Java's null it outputs "null", whereas Crystal outputs "".

  # Okay, I'm not sure if this will be allowed in the future, but I don't see any fault
  # with this. Since we can't use an Object instance variable, we can overload the
  # intialisation of the class instead so that it can act like it can take Object params.
  # But we need to know what specific types we are dealing with in the future.

  def initialize(@type : TokenType, @lexeme : String, @literal : String, @line : Int32, @null : Bool = false)
  end

  # For some reason, not providing a type for @literal will throw an error where it needs to be a String.
  def initialize(@type : TokenType, @lexeme : String, @literal : Float64, @line : Int32, @null : Bool = false)
  end

  # A token type gives a lexeme its meaning (reserved word).
  def type : TokenType
    @type
  end

  # Lexeme are grouping of characters from the source code.
  def lexeme : String
    @lexeme
  end

  # A literal is for strings and numbers. Not all lexeme are literals.
  def literal : String | Float64
    @literal
  end

  # Keep track of which line a lexeme is found.
  def line : Int32
    @line
  end

  # Used to show where a particular warning or error is.
  def to_string : String
    # Since Crystal handles nil differently to Java's null, in order to pass the provided tests,
    # we need to modify the output so it behaves like the Java implementation.
    if @null
      @literal = "null"
    end
    "#{@type} #{@lexeme} #{@literal}"
  end
end
