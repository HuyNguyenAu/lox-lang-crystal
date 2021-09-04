require "../src/scanner.cr"

class Program
  @@had_error : Bool = false

  def initialize
    if ARGC_UNSAFE > 2
      puts "Usage: jlox [script]"
      exit(64)
    elsif ARGC_UNSAFE == 2
      run_file(ARGF.gets_to_end)
    else
      run_prompt()
    end
  end

  # Execute the provided source.
  def run_file(source : String)
    run(source)

    if @@had_error
      exit(65)
    end
  end

  # WIP
  def run(source : String)
    scanner : Scanner = Scanner.new(source)
    tokens : Array(Token) = scanner.scan_tokens

    tokens.each { |token| puts token.to_string }
  end

  # Run an interactive prompt.
  def run_prompt
    loop do
      print "> "

      line : String | Nil = gets
      if line.nil?
        break
      end

      run(line)
    end
  end

  # Print out the error and line number.
  def self.error(line : Int32, message : String)
    self.report(line, "", message)
  end

  # Print out the error and line number.
  def self.report(line : Int32, where : String, message : String)
    puts "[line #{line}] Error#{where}: #{message}"
    @@had_error = true
  end
end

program = Program.new
