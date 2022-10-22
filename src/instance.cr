require "./klass.cr"

module Lox
  #
  class Instance
    def initialize(@klass : Klass)
    end

    def to_s : String
      "#{@klass.name} instance" 
    end
  end
end