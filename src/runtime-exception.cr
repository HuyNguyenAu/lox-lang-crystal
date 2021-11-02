require "../src/token.cr"

class RuntimeException < Exception
  def initialize(@token : Token, @message : String | Nil)
  end

  def token : Token
    @token
  end

  def message : String | Nil
    @message
  end
end
