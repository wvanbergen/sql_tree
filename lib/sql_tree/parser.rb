# The <tt>SQLTree::Parser</tt> class is used to construct a syntax tree
# using <tt>SQLTree::Node</tt> instances from a tree of tokens.
#
# This class does only kickstart the parsing process and manages the
# token stream that is being parsed. The actual parsing of the nodes
# occurs in the <tt>parse</tt> class method of the different node classes.
class SQLTree::Parser

  # The <tt>SQLTree::Parser::UnexpectedToken</tt> exception is thrown
  # when the parser meets a token that it not expect. 
  #
  # This exceptions usually means that an SQL syntax error has been found, 
  # however it can also mean that the SQL construct that is being used is
  # not (yet) supported by this library. Please create an issue on Github
  # if the latter is the case.
  class UnexpectedToken < StandardError

    attr_reader :expected_token, :actual_token

    def initialize(actual_token, expected_token = nil) # :nodoc:
      @expected_token, @actual_token = expected_token, actual_token
      message =  "Unexpected token: found #{actual_token.inspect}"
      message << ", but expected #{expected_token.inspect}" if expected_token
      message << '!'
      super(message)
    end
  end
  
  # Kickstarts the parser by creating a new instance with the provided
  # string, and calling the <tt>parse!</tt> method on this instance.
  #
  # Do not use this method directly, but use the <tt>SQLTree.[]</tt>
  # method instead to parse SQL strings.
  #
  # <tt>sql_string</tt>:: The string to parse
  # <tt>options</tt>:: Options to pass to the parser
  def self.parse(sql_string, options = {})
    self.new(sql_string, options).parse!
  end

  # Hash for parser options.
  attr_reader :options

  # Initializes the parser instance.
  # <tt>tokens</tt>:: The stream of tokens to turn into a syntax tree. If a 
  #                   string is given, it is tokenized automatically.
  # <tt>options</tt>:: An optional hash of parser options.
  def initialize(tokens, options = {})
    @tokens  = tokens.kind_of?(String) ? SQLTree::Tokenizer.tokenize(tokens) : tokens
    @options = options
  end

  # Returns the current token that is being parsed.
  def current
    @current_token
  end

  # Returns the next token on the token queue, and moves the token queue
  # one position forward. This will update the result of the
  # <tt>SQLTree::Parser#current</tt> method.
  def next
    @current_token = @tokens.shift
  end

  # Consumes the current token(s), which will make the parser continue to the
  # next token (see <tt>SQLTree::Parser#next</tt>).
  #
  # This method will also check if the consumed token is of the expected type.
  # It will raise a <tt>SQLTree::Parser::UnexpectedToken</tt> exception if the
  # consumed token is not of the expected type
  #
  # <tt>*checks</tt>:: a list of token types to consume.
  def consume(*checks) # :raises: SQLTree::Parser::UnexpectedToken
    checks.each do |check|
      raise UnexpectedToken.new(self.current, check) unless check === self.next
    end
  end

  # Looks at the next token on the token queue without consuming it. 
  #
  # The token queue will not be adjusted, will is the case when using 
  # <tt>SQLTree::Parser#next</tt>.
  #
  # <tt>lookahead</tt>:: the number of positions to look ahead. Defaults to 1.
  def peek(lookahead = 1)
    @tokens[lookahead - 1]
  end

  # Peeks multiple tokens at the same time.
  #
  # This method will return an array of the requested number of tokens,
  # except for when the token stream is nearing its end. In this case, the 
  # number of tokens returned can be less than requested.
  # <tt>lookahead_amount</tt>:: the amount of tokens to return from the 
  #                             front of the token queue.
  def peek_multiple(lookahead_amount)
    @tokens[0, lookahead_amount]
  end

  # Prints the current list of tokens to $stdout for inspection.
  def debug
    puts @tokens.inspect
  end

  # Parser a complete SQL query into a tree of <tt>SQLTree::Node</tt> instances.
  #
  # Currently, SELECT, INSERT, UPDATE and DELETE queries are supported for
  # the most part. This emthod should not be called directly, but is called
  # by the <tt>SQLTree.[]</tt> method, e.g.:
  #
  #   tree = SQLTree['SELECT * FROM table WHERE 1=1']
  #
  def parse!
    case self.peek
    when SQLTree::Token::SELECT then SQLTree::Node::SelectQuery.parse(self)
    when SQLTree::Token::INSERT then SQLTree::Node::InsertQuery.parse(self)
    when SQLTree::Token::DELETE then SQLTree::Node::DeleteQuery.parse(self)
    when SQLTree::Token::UPDATE then SQLTree::Node::UpdateQuery.parse(self)
    else raise UnexpectedToken.new(self.peek)
    end
  end
end
