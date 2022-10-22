require "../src/token.cr"
require "../src/callable.cr"
require "../src/runtime-exception.cr"

module Lox
  class Environment
    @values = Hash(String, Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil).new

    def initialize(@enclosing : Environment | Nil = nil)
    end

    # Hop a fixed number up the parent chain and return the enviroment.  
    def ancestor(distance : Int32) : Environment
      environment = self

      i = 0
      while i < distance
        enclosing = environment.enclosing
        environment = enclosing unless enclosing.nil?
        
        i += 1
      end

      environment
    end

    # Update a variable with a new value in the current environment.
    def assign(name : Token, value)
      if @values.has_key?(name.lexeme)
        @values[name.lexeme] = value
        return
      end
      
      unless @enclosing.nil?
        @enclosing.as(Environment).assign(name, value)
        return
      end
      
      raise RuntimeException.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    # Walk up a fixed number of environments and store a new value in the
    # environment values.
    def assign_at(distance : Int32, name : Token, value : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)
      ancestor(distance).values[name.lexeme] = value
    end
    
    # Add a new variable(binding) to the current environment.
    def define(name : String, value : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)
      @values[name] = value
    end
    
    # Try to find and return a variable by token.
    def get(name : Token) : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil
      if @values.has_key?(name.lexeme)
        return @values[name.lexeme]
      end
      
      return @enclosing.as(Environment).get(name) unless @enclosing.nil?
      
      raise RuntimeException.new(name, "Undefined variable '#{name.lexeme}'.")
    end
    
    # Get the variable using it's name and a given distance.
    def get_at(distance : Int32, name : String) : Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil
      ancestor(distance).values[name]
    end
    
    def enclosing : Environment | Nil
      @enclosing
    end

    def values
      @values
    end
  end
end
