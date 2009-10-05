module SQLTree::Node

  # Base class for all SQL expressions.
  #
  # This is an asbtract class and should not be used directly. Use
  # one of the subclasses instead.
  class Expression < Base
  
    def self.parse(tokens)
      SQLTree::Node::LogicalExpression.parse(tokens)
    end
    
    def self.parse_single(tokens)
      if SQLTree::Token::LPAREN == tokens.peek
        tokens.consume(SQLTree::Token::LPAREN)
        expr = self.parse(tokens)
        tokens.consume(SQLTree::Token::RPAREN)
        return expr
      elsif SQLTree::Token::Variable === tokens.peek(1)  && tokens.peek(2) == SQLTree::Token::LPAREN
        return SQLTree::Node::FunctionExpression.parse(tokens)  
      elsif SQLTree::Token::Variable === tokens.peek
        return SQLTree::Node::Variable.parse(tokens)
      else
        return SQLTree::Node::Value.parse(tokens)
      end      
    end
  end

  class LogicalExpression < Expression
    attr_accessor :operator, :expressions

    def initialize(operator, expressions)
      @expressions = expressions
      @operator    = operator.to_s.downcase.to_sym
    end

    def to_sql
      "(" + @expressions.map { |e| e.to_sql }.join(" #{@operator.to_s.upcase} ") + ")"
    end

    def to_tree
      [@operator] + @expressions.map { |e| e.to_tree }
    end
    
    def self.parse(tokens)
      expr = ComparisonExpression.parse(tokens)
      while [SQLTree::Token::AND, SQLTree::Token::OR].include?(tokens.peek)
        expr = SQLTree::Node::LogicalExpression.new(tokens.next.literal, [expr, ComparisonExpression.parse(tokens)])
      end 
      return expr      
    end
  end

  class ComparisonExpression < Expression
    attr_accessor :lhs, :rhs, :operator
    
    def initialize(operator, lhs, rhs)
      @lhs = lhs
      @rhs = rhs
      @operator = operator
    end
    
    def to_sql
      "(#{@lhs.to_sql} #{@operator} #{@rhs.to_sql})"
    end
    
    def to_tree
      [SQLTree::Token::OPERATORS[@operator], @lhs.to_tree, @rhs.to_tree]
    end
    
    def self.parse(tokens)
      expr = SQLTree::Node::ArithmeticExpression.parse(tokens)
      while SQLTree::Token::LOGICAL_OPERATORS.include?(tokens.peek)
        expr = self.new(tokens.next.literal, expr, SQLTree::Node::ArithmeticExpression.parse(tokens))
      end
      return expr      
    end
  end
  
  class FunctionExpression < Expression
    attr_accessor :function, :arguments
    
    def initialize(function, arguments = [])
      @function = function
      @arguments = arguments
    end
    
    def to_sql
      "#{@function}(" + @arguments.map { |e| e.to_sql }.join(', ') + ")"
    end
    
    def to_tree
      [@function.to_sym] + @arguments.map { |e| e.to_tree }
    end
    
    def self.parse(tokens)
      expr = self.new(tokens.next.literal)
      tokens.consume(SQLTree::Token::LPAREN)
      until tokens.peek == SQLTree::Token::RPAREN
        expr.arguments << SQLTree::Node::Expression.parse(tokens)
        tokens.consume(SQLTree::Token::COMMA) if tokens.peek == SQLTree::Token::COMMA
      end
      tokens.consume(SQLTree::Token::RPAREN)
      return expr      
    end
  end
  
  class ArithmeticExpression < Expression
    attr_accessor :lhs, :rhs, :operator
    
    def initialize(operator, lhs, rhs)
      @lhs = lhs
      @rhs = rhs
      @operator = operator
    end
    
    def to_sql
      "(#{@lhs.to_sql} #{@operator} #{@rhs.to_sql})"
    end
    
    def to_tree
      [SQLTree::Token::OPERATORS[@operator], @lhs.to_tree, @rhs.to_tree]
    end
    
    def self.parse(tokens)
      self.parse_primary(tokens)
    end
    
    def self.parse_primary(tokens)
      expr = self.parse_secondary(tokens)
      while [SQLTree::Token::PLUS, SQLTree::Token::MINUS].include?(tokens.peek)
        expr = self.new(tokens.next.literal, expr, self.parse_secondary(tokens))
      end
      return expr
    end
    
    def self.parse_secondary(tokens)
      expr = Expression.parse_single(tokens)
      while [SQLTree::Token::PLUS, SQLTree::Token::MINUS].include?(tokens.peek)
        expr = self.new(tokens.next.literal, expr, SQLTree::Node::Expression.parse_single(tokens))
      end
      return expr
    end
  end
end
