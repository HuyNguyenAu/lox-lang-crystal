require "../src/token-type.cr"

class Token
  @type : TokenType = TokenType::NOVAL
  @lexeme : String = ""
  @literal : String | Float64
  @line : Int32 = 0
  @null : Bool = false # Used to pass tests since Crystal does not support nil like Java's null.
  # When you print Java's null it outputs "null", whereas Crystal outputs "".

  # Okay, I'm not sure if this will be allowed in the future, but I don't see any fault
  # with this. Since we can't use an Object instance variable, we can overload the
  # intialisation of the class instead so that it can act like it can take Object params.
  # But we need to know what specific types we are dealing with in the future.

  def initialize(type : TokenType, lexeme : String, literal : String, line : Int32, null : Bool = false)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
    @null = null
  end

  def initialize(type : TokenType, lexeme : String, literal : Float64, line : Int32, null : Bool = false)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
    @null = null
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
