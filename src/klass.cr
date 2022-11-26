require "./callable.cr"
require "./function.cr"
require "./instance.cr"

module Lox
  #
  class Klass < Callable
    def initialize(@name : String, @superClass : self | Nil, @methods : Hash(String, Lox::Function))
    end

    def call(interpreter : Interpreter, arguments : Array(Bool | Float64 | Lox::Callable | Lox::Expression | Lox::Instance | String | Nil)) : Lox::Instance
      instance = Instance.new(self)

      initialiser = find_method("init")

      # If we find an 'init' method, bind this instance and invoke it like a normal
      # method.
      unless initialiser.nil?
        initialiser.bind(instance).call(interpreter, arguments)
      end

      instance
    end

    def find_method(name : String) : Lox::Function | Nil
      if @methods.has_key?(name)
        return @methods[name]
      end

      superClass = @superClass

      unless superClass.nil?
        return superClass.find_method(name)
      end

      nil
    end

    def name : String
      @name
    end

    def methods : String
      @methods
    end

    def arity : Int32
      initialiser = find_method("init")

      if initialiser.nil?
        return 0
      end

      initialiser.arity
    end

    def to_s : String
      @name
    end
  end
end
