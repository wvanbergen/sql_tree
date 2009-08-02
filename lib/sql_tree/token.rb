class SQLTree::Token

  attr_accessor :literal

  def initialize(literal)
    @literal = literal
  end
  
  def ==(other)
    other.class == self.class && @literal == other.literal
  end
  
  alias :eql? :==
  
  def inspect
    literal
  end
  
  # Token types
  
  class Variable < SQLTree::Token
    # def inspect
    #   literal.inspect
    # end
  end
  
  class String < SQLTree::Token
    def inspect
      literal.inspect
    end    
  end
  
  class Number < SQLTree::Token
    def inspect
      literal
    end    
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
  DOT =    Class.new(SQLTree::Token).new('.')  
  
  KEYWORDS = %w{select from where group having order distinct left right inner outer join and or not as}
  KEYWORDS.each do |kw|
    self.const_set(kw.upcase, Class.new(SQLTree::Token::Keyword).new(kw.upcase))
  end
  
  OPERATORS = { '+' => :plus, '-' => :minus, '*' => :multiply, '/' => :divide, '%' => :modulo,
      '=' => :eq, '!=' => :ne, '<>' => :ne, '>' => :gt, '<' => :lt, '>=' => :gte, '<=' => :lte }
  OPERATORS.each do |literal, symbol|
    self.const_set(symbol.to_s.upcase, Class.new(SQLTree::Token::Operator).new(literal)) unless self.const_defined?(symbol.to_s.upcase)
  end

end
