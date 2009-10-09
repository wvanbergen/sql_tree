class SQLTree::Token

  attr_accessor :literal

  def initialize(literal)
    @literal = literal
  end
  
  def ==(other)
    other.class == self.class && @literal == other.literal
  end
  
  def inspect
    literal
  end
  
  # Token types
  
  class Value < SQLTree::Token
    def inspect
      "#<#{self.class.name.split('::').last}:#{literal.inspect}>"
    end
  end
  
  class Variable < SQLTree::Token::Value
  end
  
  class String < SQLTree::Token::Value
  end
  
  class Number < SQLTree::Token::Value
  end  
  
  class Keyword < SQLTree::Token
    def inspect
      ":#{literal.downcase}"
    end
  end

  class Operator < SQLTree::Token
    def inspect
      OPERATORS_HASH[literal].inspect
    end
  end
  
  # Create some static token classes and a single instance of them
  LPAREN = Class.new(SQLTree::Token).new('(')
  RPAREN = Class.new(SQLTree::Token).new(')')
  DOT    = Class.new(SQLTree::Token).new('.')
  COMMA  = Class.new(SQLTree::Token).new(',')

  # A list of all the SQL reserverd keywords.
  KEYWORDS = %w{SELECT FROM WHERE GOUP HAVING ORDER DISTINCT LEFT RIGHT INNER FULL OUTER NATURAL JOIN USING 
                AND OR NOT AS ON IS NULL BY LIKE ILIKE BETWEEN}

  # Create a token for all the reserved keywords in SQL
  KEYWORDS.each { |kw| const_set(kw, Class.new(SQLTree::Token::Keyword).new(kw)) }

  # A list of keywords that aways occur in fixed combinations. Register these as separate keywords.
  KEYWORD_COMBINATIONS = [%w{IS NOT}, %w{NOT LIKE}, %w{NOT BETWEEN}, %w{NOT ILIKE}]
  KEYWORD_COMBINATIONS.each { |kw| const_set(kw.join('_'), Class.new(SQLTree::Token::Keyword).new(kw.join(' '))) }

  ARITHMETHIC_OPERATORS_HASH = { '+' => :plus, '-' => :minus, '*' => :multiply, '/' => :divide, '%' => :modulo }
  COMPARISON_OPERATORS_HASH  = { '=' => :eq, '!=' => :ne, '<>' => :ne, '>' => :gt, '<' => :lt, '>=' => :gte, '<=' => :lte }

  OPERATORS_HASH = ARITHMETHIC_OPERATORS_HASH.merge(COMPARISON_OPERATORS_HASH)
  OPERATORS_HASH.each_pair do |literal, symbol|
    self.const_set(symbol.to_s.upcase, Class.new(SQLTree::Token::Operator).new(literal)) unless self.const_defined?(symbol.to_s.upcase)
  end
  
  COMPARISON_OPERATORS = COMPARISON_OPERATORS_HASH.map { |(literal, symbol)| const_get(symbol.to_s.upcase) } +
      [SQLTree::Token::IS, SQLTree::Token::IS_NOT, SQLTree::Token::LIKE, SQLTree::Token::NOT_LIKE,
       SQLTree::Token::ILIKE, SQLTree::Token::NOT_ILIKE]
end
