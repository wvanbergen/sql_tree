class SQLTree::Parser

  class UnexpectedToken < StandardError

    attr_reader :expected_token, :actual_token

    def initialize(actual_token, expected_token = nil)
      @expected_token, @actual_token = expected_token, actual_token
      message =  "Unexpected token: found #{actual_token.inspect}"
      message << ", but expected #{expected_token.inspect}" if expected_token
      message << '!'
      super(message)
    end
  end

  def self.parse(sql_string, options = {})
    self.new(sql_string, options).parse!
  end

  attr_reader :options

  def initialize(tokens, options)
    if tokens.kind_of?(String)
      @tokens = SQLTree::Tokenizer.new.tokenize(tokens)
    else
      @tokens = tokens
    end
    @options = options
  end

  def current
    @current_token
  end

  def next
    @current_token = @tokens.shift
  end

  def consume(*checks)
    checks.each do |check|
      raise UnexpectedToken.new(self.current, check) unless check == self.next
    end
  end

  def peek(distance = 1)
    @tokens[distance - 1]
  end

  def peek_tokens(amount)
    @tokens[0, amount]
  end

  def debug
    puts @tokens.inspect
  end

  def parse!
    case self.peek
    when SQLTree::Token::SELECT then SQLTree::Node::SelectQuery.parse(self)
    when SQLTree::Token::INSERT then SQLTree::Node::InsertQuery.parse(self)      
    else raise UnexpectedToken.new(self.peek)
    end
  end
end
