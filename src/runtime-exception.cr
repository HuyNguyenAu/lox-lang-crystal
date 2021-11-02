require "../src/token.cr"

class RuntimeException < Exception
  def initialize(@token : Token, @message : String)
  end

  def token
    @token
  end

  def message
    @message
  end
end
