# The <tt>SQLTree::Token</tt> class is the base class for every token
# in the SQL language. Actual tokens are represented by a subclass.
#
# Tokens are produced by the <tt>SQLTree::Tokenizer</tt> from a string
# and are consumed by the <tt>SQLTree::Parser</tt> to construct an
# abstract syntax tree for the query that is being parsed.
class SQLTree::Token

  # For some tokens, the encountered literal value is important
  # during the parsing phase (e.g. strings and variable names).
  # Therefore, the literal value encountered that represented the
  # token in the original SQL query string is stored.
  attr_accessor :literal

  # Creates a token instance with a given literal representation.
  #
  # <tt>literal<tt>:: The literal string value that was encountered
  #                   while tokenizing.
  def initialize(literal)
    @literal = literal
  end

  # Compares two tokens. Tokens are considered equal when they are
  # instances of the same class, i.e. do literal is not used.
  def ==(other)
    other.class == self.class
  end

  def inspect # :nodoc:
    literal
  end

  def join?
    [SQLTree::Token::JOIN, SQLTree::Token::LEFT, SQLTree::Token::RIGHT,
      SQLTree::Token::INNER, SQLTree::Token::OUTER, SQLTree::Token::NATURAL,
      SQLTree::Token::FULL].include?(self)
  end

  def direction?
    [SQLTree::Token::ASC, SQLTree::Token::DESC].include?(self)
  end

  ###################################################################
  # DYNAMIC TOKEN TYPES
  ###################################################################

  # The <tt>SQLTree::Token::Value</tt> class is the base class for
  # every dynamic token. A dynamic token is a token for which the
  # literal value used remains impoirtant during parsing.
  class Value < SQLTree::Token

    def inspect # :nodoc:
      "#<#{self.class.name.split('::').last}:#{literal.inspect}>"
    end

    # Compares two tokens. For values, the literal encountered value
    # of the token is also taken into account besides the class.
    def ==(other)
      other.class == self.class && @literal == other.literal
    end
  end

  # The <tt>SQLTree::Token::Variable</tt> class represents SQL
  # variables. The variable name is stored in the literal as string,
  # without quotes if they were present.
  class Variable < SQLTree::Token::Value
  end

  # The <tt>SQLTree::Token::String</tt> class represents strings.
  # The actual string is stored in the literal as string without quotes.
  class String < SQLTree::Token::Value
  end

  # The <tt>SQLTree::Token::Keyword</tt> class represents numbers.
  # The actual number is stored as an integer or float in the token's
  # literal.
  class Number < SQLTree::Token::Value
  end

  ###################################################################
  # STATIC TOKEN TYPES
  ###################################################################

  # The <tt>SQLTree::Token::Keyword</tt> class represents reserved SQL
  # keywords. These keywords are used to structure the query. Keywords
  # are static, i.e. the literal value is not important during the
  # parsing process.
  class Keyword < SQLTree::Token
    def inspect # :nodoc:
      ":#{literal.gsub(/ /, '_').downcase}"
    end
  end

  # The <tt>SQLTree::Token::Operator</tt> class represents logical and
  # arithmetic operators in SQL. These tokens are static, i.e. the literal
  # value is not important during the parsing process.
  class Operator < SQLTree::Token
    def inspect # :nodoc:
      OPERATORS_HASH[literal].inspect
    end
  end

  ###################################################################
  # STATIC TOKEN CONSTANTS
  ###################################################################

  # Create some static token classes and a single instance of them
  LPAREN = Class.new(SQLTree::Token).new('(')
  RPAREN = Class.new(SQLTree::Token).new(')')
  DOT    = Class.new(SQLTree::Token).new('.')
  COMMA  = Class.new(SQLTree::Token).new(',')

  # A list of all the SQL reserverd keywords.
  KEYWORDS = %w{SELECT FROM WHERE GROUP HAVING ORDER DISTINCT LEFT RIGHT INNER FULL OUTER NATURAL JOIN USING
                AND OR NOT AS ON IS NULL BY LIKE ILIKE BETWEEN IN ASC DESC INSERT INTO VALUES DELETE UPDATE SET}

  # Create a token for all the reserved keywords in SQL
  KEYWORDS.each { |kw| const_set(kw, Class.new(SQLTree::Token::Keyword).new(kw)) }

  # A list of keywords that aways occur in fixed combinations. Register these as separate keywords.
  KEYWORD_COMBINATIONS = [%w{IS NOT}, %w{NOT LIKE}, %w{NOT BETWEEN}, %w{NOT ILIKE}]
  KEYWORD_COMBINATIONS.each { |kw| const_set(kw.join('_'), Class.new(SQLTree::Token::Keyword).new(kw.join(' '))) }

  ARITHMETHIC_OPERATORS_HASH = { '+' => :plus, '-' => :minus, '*' => :multiply, '/' => :divide, '%' => :modulo }
  COMPARISON_OPERATORS_HASH  = { '=' => :eq, '!=' => :ne, '<>' => :ne, '>' => :gt, '<' => :lt, '>=' => :gte, '<=' => :lte }

  # Register a token class and single instance for every token.
  OPERATORS_HASH = ARITHMETHIC_OPERATORS_HASH.merge(COMPARISON_OPERATORS_HASH)
  OPERATORS_HASH.each_pair do |literal, symbol|
    self.const_set(symbol.to_s.upcase, Class.new(SQLTree::Token::Operator).new(literal)) unless self.const_defined?(symbol.to_s.upcase)
  end

  COMPARISON_OPERATORS = COMPARISON_OPERATORS_HASH.map { |(literal, symbol)| const_get(symbol.to_s.upcase) } +
    [SQLTree::Token::IN, SQLTree::Token::IS, SQLTree::Token::BETWEEN, SQLTree::Token::LIKE, SQLTree::Token::ILIKE, SQLTree::Token::NOT]
end
