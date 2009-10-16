# The <tt>SQLTree::Tokenizer</tt> class transforms a string or stream of
# characters into a enumeration of tokens, that are more appropriate for
# the SQL parser to work with.
#
# An example:
#
#   >> SQLTree::Tokenizer.new.tokenize('SELECT * FROM table')
#   => [:select, :all, :from, Variable('table')]
#
# The <tt>tokenize</tt> method will return an array of tokens, while
# the <tt>each_token</tt> (aliased to <tt>each</tt>) will yield every
# token one by one.
class SQLTree::Tokenizer

  include Enumerable

  # Returns an array of tokens for the given string.
  # <tt>string</tt>:: the string to tokenize
  def self.tokenize(string)
    self.new(string).tokens
  end

  # The keyword queue, on which kywords are placed before they are yielded
  # to the parser, to enable keyword combining (e.g. NOT LIKE)
  attr_reader :keyword_queue

  def initialize(string) # :nodoc:
    @string = string
    @current_char_pos = -1
    @keyword_queue = []
  end

  # Tokeinzes the string and returns all tokens as an array
  def tokens
    self.entries
  end

  # Returns the current character that is being tokenized
  def current_char
    @current_char
  end

  # Returns the next character to tokenize, but does not move
  # the pointer of the current character forward.
  # <tt>lookahead</tt>:: how many positions forward to peek.
  def peek_char(lookahead = 1)
    @string[@current_char_pos + lookahead, 1]
  end

  # Returns the next character to tokenize, and moves the pointer
  # of the current character one position forward.
  def next_char
    @current_char_pos += 1
    @current_char = @string[@current_char_pos, 1]
  end

  # Combines several tokens to a single token if possible, and
  # yields teh result, or yields every single token if they cannot
  # be combined.
  # <tt>token</tt>:: the token to yield or combine
  # <tt>block</tt>:: the block to yield tokens and combined tokens to.
  def handle_token(token, &block) # :yields: SQLTree::Token
    if token.kind_of?(SQLTree::Token::Keyword)
      keyword_queue.push(token)
    else
      empty_keyword_queue!(&block)
      block.call(token)
    end
  end

  # This method ensures that every keyword currently in the queue is
  # yielded. This method get called by <tt>handle_token</tt> when it
  # knows for sure that the keywords on the queue cannot be combined
  # into a single keyword.
  # <tt>block</tt>:: the block to yield the tokens on the queue to.
  def empty_keyword_queue!(&block) # :yields: SQLTree::Token
    block.call(@keyword_queue.shift) until @keyword_queue.empty?
  end

  # Iterator method that yields each token that is encountered in the
  # SQL stream. These tokens are passed to the SQL parser to construct
  # a syntax tree for the SQL query.
  #
  # This method is aliased to <tt>:each</tt> to make the Enumerable
  # methods work on this method.
  def each_token(&block) # :yields: SQLTree::Token
    
    while next_char
      case current_char
      when /^\s?$/;        # whitespace, go to next character
      when '(';            handle_token(SQLTree::Token::LPAREN, &block)
      when ')';            handle_token(SQLTree::Token::RPAREN, &block)
      when '.';            handle_token(SQLTree::Token::DOT, &block)
      when ',';            handle_token(SQLTree::Token::COMMA, &block)
      when /\d/;           tokenize_number(&block)
      when "'";            tokenize_quoted_string(&block)
      when /\w/;           tokenize_keyword(&block)
      when OPERATOR_CHARS; tokenize_operator(&block)
      when SQLTree.identifier_quote_char; tokenize_quoted_identifier(&block)
      end
    end

    # Make sure to yield any tokens that are still stashed on the queue.
    empty_keyword_queue!(&block)
  end

  alias :each :each_token

  # Tokenizes a eyword in the code. This can either be a reserved SQL keyword
  # or a variable. This method will yield variables directly. Keywords will be
  # yielded with a delay, because they may need to be combined with other
  # keywords in the <tt>handle_token</tt> method.
  def tokenize_keyword(&block) # :yields: SQLTree::Token
    literal = current_char
    literal << next_char while /[\w]/ =~ peek_char

    if SQLTree::Token::KEYWORDS.include?(literal.upcase)
      handle_token(SQLTree::Token.const_get(literal.upcase).new(literal), &block)
    else
      handle_token(SQLTree::Token::Identifier.new(literal), &block)
    end
  end

  # Tokenizes a number (either an integer or float) in the SQL stream.
  # This method will yield the token after the last digit of the number
  # has been encountered.
  def tokenize_number(&block) # :yields: SQLTree::Token::Number
    number = current_char
    dot_encountered = false
    while /\d/ =~ peek_char || (peek_char == '.' && !dot_encountered)
      dot_encountered = true if peek_char == '.'
      number << next_char
    end

    if dot_encountered
      handle_token(SQLTree::Token::Number.new(number.to_f), &block)
    else
      handle_token(SQLTree::Token::Number.new(number.to_i), &block)
    end
  end

  # Reads a quoted string token from the SQL stream. This method will
  # yield an SQLTree::Token::String when the closing quote character is
  # encountered.
  def tokenize_quoted_string(&block) # :yields: SQLTree::Token::String
    string = ''
    until next_char.nil? || current_char == "'"
      string << (current_char == "\\" ? next_char : current_char)
    end
    handle_token(SQLTree::Token::String.new(string), &block)
  end

  # Tokenize a quoted variable from the SQL stream. This method will
  # yield an SQLTree::Token::Identifier when to closing quote is found.
  #
  # The actual quote character that is used depends on the DBMS. For now,
  # only the more standard double quote is accepted.
  def tokenize_quoted_identifier(&block) # :yields: SQLTree::Token::Identifier
    variable = ''
    until next_char.nil? || current_char == SQLTree.identifier_quote_char # TODO: allow MySQL quoting mode
      variable << (current_char == "\\" ? next_char : current_char)
    end
    handle_token(SQLTree::Token::Identifier.new(variable), &block)
  end

  # A regular expression that matches all operator characters.
  OPERATOR_CHARS = /\=|<|>|!|\-|\+|\/|\*|\%|\||\&/

  # Tokenizes an operator in the SQL stream. This method will yield the
  # operator token when the last character of the token is encountered.
  def tokenize_operator(&block) # :yields: SQLTree::Token
    operator = current_char
    if operator == '-' && /[\d\.]/ =~ peek_char
      tokenize_number(&block)
    else
      operator << next_char if SQLTree::Token::OPERATORS_HASH.has_key?(operator + peek_char)
      operator_class = SQLTree::Token.const_get(SQLTree::Token::OPERATORS_HASH[operator].to_s.upcase)
      handle_token(operator_class.new(operator), &block)
    end
  end
end
