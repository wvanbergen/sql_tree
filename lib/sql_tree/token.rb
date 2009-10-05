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
      OPERATORS[literal].inspect
    end
  end

  LPAREN = Class.new(SQLTree::Token).new('(')
  RPAREN = Class.new(SQLTree::Token).new(')')
  DOT    = Class.new(SQLTree::Token).new('.')  
  COMMA  = Class.new(SQLTree::Token).new(',')    
  
  KEYWORDS = %w{select from where group having order distinct left right inner full outer natural join using and or not as on}
  KEYWORDS.each do |kw|
    self.const_set(kw.upcase, Class.new(SQLTree::Token::Keyword).new(kw.upcase))
  end
  
  ARITHMETHIC_OPERATORS = { '+' => :plus, '-' => :minus, '*' => :multiply, '/' => :divide, '%' => :modulo }
  LOGICAL_OPERATORS     = { '=' => :eq, '!=' => :ne, '<>' => :ne, '>' => :gt, '<' => :lt, '>=' => :gte, '<=' => :lte }

  OPERATORS = ARITHMETHIC_OPERATORS.merge(LOGICAL_OPERATORS)
  OPERATORS.each do |literal, symbol|
    self.const_set(symbol.to_s.upcase, Class.new(SQLTree::Token::Operator).new(literal)) unless self.const_defined?(symbol.to_s.upcase)
  end

end
