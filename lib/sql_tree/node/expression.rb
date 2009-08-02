class SQLTree::Node
  
  class Expression < SQLTree::Node
  
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
    
  end
  
  class AllFieldsExpression < Expression
    def to_sql
      '*'
    end
  end
  
  ALL_FIELDS = AllFieldsExpression.new  
  
end